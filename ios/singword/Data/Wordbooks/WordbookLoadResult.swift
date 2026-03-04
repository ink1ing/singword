import Foundation

enum WordbookLoadResult {
    case success(words: [String: (WordEntry, String)])
    case missingAsset(assetPath: String)
    case parseError(assetPath: String, reason: String)
}
