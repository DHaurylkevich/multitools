extension AppAction {
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
}

extension AppActionGroup {
    var icon: String { "character.bubble" }
}
