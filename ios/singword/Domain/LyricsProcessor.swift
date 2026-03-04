import Foundation

enum LyricsProcessor {
    nonisolated static func normalizeToken(_ raw: String) -> String {
        raw
            .replacingOccurrences(of: "’", with: "'")
            .lowercased()
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "[^a-z]", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    nonisolated static func tokenize(_ lyrics: String) -> Set<String> {
        Set(
            lyrics
                .components(separatedBy: .whitespacesAndNewlines)
                .map(normalizeToken)
                .filter { $0.count > 1 }
        )
    }
}
