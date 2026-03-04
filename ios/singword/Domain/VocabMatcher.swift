import Foundation

enum VocabMatcher {
    static func match(
        tokens: Set<String>,
        wordbooks: [String: (WordEntry, String)]
    ) -> [MatchedWord] {
        tokens
            .compactMap { token in
                guard let (entry, source) = wordbooks[token] else {
                    return nil
                }
                return MatchedWord(
                    word: entry.word,
                    pos: entry.pos,
                    definition: entry.definition,
                    source: source
                )
            }
            .sorted { $0.word < $1.word }
    }
}
