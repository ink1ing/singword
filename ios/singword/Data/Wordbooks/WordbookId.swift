import Foundation

enum WordbookId: String, CaseIterable, Codable, Hashable {
    case cet4
    case cet6
    case ielts
    case toefl

    var label: String {
        switch self {
        case .cet4:
            return "CET-4"
        case .cet6:
            return "CET-6"
        case .ielts:
            return "IELTS"
        case .toefl:
            return "TOEFL"
        }
    }
}
