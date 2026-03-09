import Foundation

private struct MusicBrainzResponse: Decodable {
    let recordings: [MusicBrainzRecording]
}

private struct MusicBrainzRecording: Decodable {
    struct ArtistCredit: Decodable {
        let name: String?
    }

    let title: String
    let length: Int?
    let artistCredit: [ArtistCredit]

    enum CodingKeys: String, CodingKey {
        case title
        case length
        case artistCredit = "artist-credit"
    }
}

struct MusicBrainzRecordingCandidate: Sendable {
    let title: String
    let artistName: String
    let duration: TimeInterval?
}

final class MusicBrainzRecordingResolver {
    private let session: URLSession

    init(session: URLSession? = nil) {
        if let session {
            self.session = session
        } else {
            let config = URLSessionConfiguration.ephemeral
            config.timeoutIntervalForRequest = 8
            config.timeoutIntervalForResource = 8
            self.session = URLSession(configuration: config)
        }
    }

    func search(title: String, artist: String, isrc: String) async -> [MusicBrainzRecordingCandidate] {
        let query: String
        if !isrc.isEmpty {
            query = "isrc:\(isrc)"
        } else {
            query = #"recording:"\#(title)" AND artist:"\#(artist)""#
        }

        guard var components = URLComponents(string: "https://musicbrainz.org/ws/2/recording") else {
            return []
        }
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "fmt", value: "json"),
            URLQueryItem(name: "limit", value: "10")
        ]

        guard let url = components.url else {
            return []
        }

        var request = URLRequest(url: url)
        request.setValue("SingWord/1.0 ( https://github.com/ink1ing/singword )", forHTTPHeaderField: "User-Agent")

        do {
            let (data, response) = try await session.data(for: request)
            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                return []
            }

            let decoded = try JSONDecoder().decode(MusicBrainzResponse.self, from: data)
            return decoded.recordings.map { recording in
                MusicBrainzRecordingCandidate(
                    title: recording.title,
                    artistName: recording.artistCredit.compactMap(\.name).joined(separator: " "),
                    duration: recording.length.map { TimeInterval($0) / 1000.0 }
                )
            }
        } catch {
            return []
        }
    }
}
