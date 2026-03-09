import Foundation

private struct LrclibTrack: Decodable {
    let id: Int?
    let trackName: String?
    let artistName: String?
    let albumName: String?
    let duration: Double?
    let plainLyrics: String?
    let syncedLyrics: String?
}

final class LrclibLyricsDataSource: LyricsDataSource, LyricsCandidateDataSource {
    let providerName: String = "lrclib"

    private let session: URLSession

    init(session: URLSession? = nil) {
        if let session {
            self.session = session
        } else {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 10
            config.timeoutIntervalForResource = 10
            self.session = URLSession(configuration: config)
        }
    }

    func search(query: String) async -> LyricsResult {
        switch await searchCandidates(query: query, limit: 1) {
        case .success(let candidates, _):
            guard let selected = candidates.first else {
                return .notFound
            }
            return .success(
                trackName: selected.trackName,
                artistName: selected.artistName,
                lyrics: selected.lyrics,
                provider: selected.provider
            )
        case .notFound:
            return .notFound
        case .networkError(let message):
            return .networkError(message)
        case .providerError(let provider, let message):
            return .providerError(provider: provider, message: message)
        }
    }

    func searchCandidates(query: String, limit: Int = 5) async -> LyricsCandidateResult {
        guard var components = URLComponents(string: "https://lrclib.net/api/search") else {
            return .providerError(provider: providerName, message: "无效的歌词服务地址")
        }
        components.queryItems = [
            URLQueryItem(name: "q", value: query)
        ]
        guard let url = components.url else {
            return .providerError(provider: providerName, message: "无效的请求参数")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("SingWord/1.0.0", forHTTPHeaderField: "User-Agent")

        do {
            let (data, response) = try await session.data(for: request)
            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                return .providerError(
                    provider: providerName,
                    message: "歌词服务异常（HTTP \(httpResponse.statusCode)）"
                )
            }

            let tracks = try JSONDecoder().decode([LrclibTrack].self, from: data)
            let candidates = tracks
                .filter { !($0.plainLyrics?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) }
                .prefix(max(1, limit))
                .map { track in
                    let normalizedTrackName = track.trackName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    return LyricsCandidate(
                        trackName: normalizedTrackName.isEmpty ? query : normalizedTrackName,
                        artistName: track.artistName ?? "",
                        lyrics: track.plainLyrics ?? "",
                        provider: providerName,
                        duration: track.duration
                    )
                }

            if candidates.isEmpty {
                return .notFound
            }

            return .success(candidates: candidates, provider: providerName)
        } catch let error as URLError {
            _ = error
            return .networkError("网络异常，请检查连接后重试")
        } catch {
            return .providerError(provider: providerName, message: error.localizedDescription)
        }
    }
}
