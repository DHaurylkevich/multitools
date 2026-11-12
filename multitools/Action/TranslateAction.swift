import SwiftUI

enum TranslateAction: String, CaseIterable, Identifiable {
    case text
    case screenshot

    var id: Self { self }

    var title: String {
        switch self {
        case .text: return "Text"
        case .screenshot: return "Screenshot"
        }
    }

    var icon: String {
        switch self {
        case .text: return "text.alignleft"
        case .screenshot: return "camera"
        }
    }

    var color: Color {
        switch self {
        case .text: return .blue
        case .screenshot: return .orange
        }
    }
}
