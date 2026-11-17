enum AppAction: String, CaseIterable, Identifiable {
    case translateText
    case translateScreenshot
    case askAI
    case grammar

    var id: String { rawValue }

    var group: AppActionGroup? {
        switch self {
        case .translateText, .translateScreenshot:
            return .translate
        case .askAI, .grammar:
            return nil
        }
    }
}

enum AppActionGroup: String, Identifiable {
    case translate

    var id: String { rawValue }

    var actions: [AppAction] {
        AppAction.allCases.filter { $0.group == self }
    }
}
