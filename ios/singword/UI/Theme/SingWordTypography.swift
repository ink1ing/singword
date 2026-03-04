import SwiftUI
import CoreText

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

    static var headlineLarge: Font { .custom(headingName, size: 28).weight(.bold) }
    static var headlineMedium: Font { .custom(headingName, size: 22).weight(.semibold) }
    static var titleLarge: Font { .custom(headingName, size: 18).weight(.semibold) }
    static var titleMedium: Font { .custom(headingName, size: 16).weight(.medium) }

    static var bodyLarge: Font { .custom(bodyName, size: 16).weight(.regular) }
    static var bodyMedium: Font { .custom(bodyName, size: 14).weight(.regular) }
    static var labelMedium: Font { .custom(bodyName, size: 12).weight(.medium) }
    static var labelSmallBold: Font { .custom(bodyName, size: 10).weight(.bold) }
}
