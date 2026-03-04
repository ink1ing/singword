import SwiftUI

enum SingWordPalette {
    static let lightBackground = Color(red: 245 / 255, green: 240 / 255, blue: 235 / 255)
    static let lightSurface = Color(red: 255 / 255, green: 253 / 255, blue: 250 / 255)
    static let lightSurfaceVariant = Color(red: 237 / 255, green: 229 / 255, blue: 221 / 255)
    static let lightTextPrimary = Color(red: 26 / 255, green: 26 / 255, blue: 24 / 255)
    static let lightTextSecondary = Color(red: 107 / 255, green: 107 / 255, blue: 107 / 255)
    static let lightLink = Color(red: 139 / 255, green: 94 / 255, blue: 60 / 255)

    static let darkBackground = Color(red: 28 / 255, green: 27 / 255, blue: 25 / 255)
    static let darkSurface = Color(red: 36 / 255, green: 35 / 255, blue: 32 / 255)
    static let darkSurfaceVariant = Color(red: 46 / 255, green: 45 / 255, blue: 42 / 255)
    static let darkTextPrimary = Color(red: 236 / 255, green: 236 / 255, blue: 236 / 255)
    static let darkTextSecondary = Color(red: 155 / 255, green: 155 / 255, blue: 155 / 255)
    static let darkLink = Color(red: 200 / 255, green: 169 / 255, blue: 126 / 255)

    static let tagCET4 = Color(red: 79 / 255, green: 195 / 255, blue: 247 / 255)
    static let tagCET6 = Color(red: 129 / 255, green: 199 / 255, blue: 132 / 255)
    static let tagIELTS = Color(red: 255 / 255, green: 183 / 255, blue: 77 / 255)
    static let tagTOEFL = Color(red: 229 / 255, green: 115 / 255, blue: 115 / 255)

    static let error = Color(red: 179 / 255, green: 38 / 255, blue: 30 / 255)
}

extension Color {
    static var tagCET4: Color { SingWordPalette.tagCET4 }
    static var tagCET6: Color { SingWordPalette.tagCET6 }
    static var tagIELTS: Color { SingWordPalette.tagIELTS }
    static var tagTOEFL: Color { SingWordPalette.tagTOEFL }
    static var singWordError: Color { SingWordPalette.error }

    static func sourceTag(_ source: String) -> Color {
        switch source {
        case "CET-4":
            return .tagCET4
        case "CET-6":
            return .tagCET6
        case "IELTS":
            return .tagIELTS
        case "TOEFL":
            return .tagTOEFL
        default:
            return .secondary
        }
    }
}
