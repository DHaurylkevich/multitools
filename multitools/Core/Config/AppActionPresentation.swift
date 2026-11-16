import SwiftUI

extension AppAction {
    var title: String {
        switch self {
        case .translateText: return "Text"
        case .translateScreenshot: return "Screenshot"
        case .askAI: return "Ask AI"
        case .grammar: return "Grammar"
        }
    }

    var windowTitle: String {
        switch self {
        case .translateText, .translateScreenshot: return "Translate"
        case .askAI: return "Ask AI"
        case .grammar: return "Grammar & Style Check"
        }
    }

    var icon: String {
        switch self {
        case .translateText: return "text.alignleft"
        case .translateScreenshot: return "camera"
        case .askAI: return "sparkles"
        case .grammar: return "pencil.and.outline"
        }
    }

    var color: Color {
        switch self {
        case .translateText: return .blue
        case .translateScreenshot: return .orange
        case .askAI: return .blue
        case .grammar: return .green
        }
    }
}

extension AppActionGroup {
    var title: String { "Translate" }
    var icon: String { "character.bubble" }
    var color: Color { .purple }
}
