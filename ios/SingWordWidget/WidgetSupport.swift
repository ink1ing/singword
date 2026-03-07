import SwiftUI
import Foundation
import CoreText

enum SingWordShared {
    static let appGroupIdentifier = "group.ink.singword.shared"
    static let widgetKind = "SingWordWidget"
    static let recentSearchesFileName = "recent_searches.json"

    static func sharedDefaults() -> UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }

    static func sharedContainerDirectory(fileManager: FileManager = .default) -> URL? {
        fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)?
            .appendingPathComponent("SingWord", isDirectory: true)
    }
}

enum AppThemeMode: String, CaseIterable, Codable {
    case system
    case light
    case dark
}

struct WidgetWordSnapshot: Codable, Hashable, Identifiable {
    var id: String { word }

    let word: String
    let pos: String
    let definition: String
}

struct SearchWidgetSnapshot: Codable {
    let trackName: String
    let artistName: String
    let words: [WidgetWordSnapshot]
    let updatedAt: TimeInterval
}

struct RecentSearchWidgetSnapshot: Codable {
    let trackName: String
    let artistName: String
    let provider: String
    let totalTokens: Int
    let matchedWords: [WidgetWordSnapshot]
    let timestamp: TimeInterval
}

enum SingWordFontRegistrar {
    static func registerAll() {
        registerFont(named: "inter_variable", ext: "ttf", subdirectory: "fonts")
        registerFont(named: "plus_jakarta_sans_variable", ext: "ttf", subdirectory: "fonts")
    }

    private static func registerFont(named: String, ext: String, subdirectory: String) {
        let bundle = Bundle.main
        let primaryURL = bundle.url(forResource: named, withExtension: ext, subdirectory: subdirectory)
        let fallbackURL = bundle.url(forResource: named, withExtension: ext)

        guard let fontURL = primaryURL ?? fallbackURL else {
            return
        }

        CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
    }
}

enum SingWordTypography {
    private static let headingName = "PlusJakartaSans-Regular"
    private static let bodyName = "Inter-Regular"

    static var titleLarge: Font { .custom(headingName, size: 18).weight(.semibold) }
    static var titleMedium: Font { .custom(headingName, size: 16).weight(.medium) }
    static var bodyMedium: Font { .custom(bodyName, size: 14).weight(.regular) }
}

enum SingWordPalette {
    static let lightBackground = Color(red: 245 / 255, green: 240 / 255, blue: 235 / 255)
    static let lightTextPrimary = Color(red: 26 / 255, green: 26 / 255, blue: 24 / 255)
    static let lightTextSecondary = Color(red: 107 / 255, green: 107 / 255, blue: 107 / 255)

    static let darkBackground = Color(red: 28 / 255, green: 27 / 255, blue: 25 / 255)
    static let darkTextPrimary = Color(red: 236 / 255, green: 236 / 255, blue: 236 / 255)
    static let darkTextSecondary = Color(red: 155 / 255, green: 155 / 255, blue: 155 / 255)
}
