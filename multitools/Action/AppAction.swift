import SwiftUI

/// Полный список действий приложения — единственный источник правды.
///
/// Из `allCases` строится радиальное меню (`RadialMenuBuilder`), а маршрутизация
/// в `ActionRouter` проверяется компилятором на исчерпываемость `switch`.
/// Поэтому новый кейс невозможно «забыть» в каком-то одном списке.
enum AppAction: String, CaseIterable, Identifiable {
    case translateText
    case translateScreenshot
    case askAI
    case grammar

    var id: String { rawValue }

    /// Подменю, в котором показывается действие. `nil` — верхний уровень меню.
    var group: AppActionGroup? {
        switch self {
        case .translateText, .translateScreenshot:
            return .translate
        case .askAI, .grammar:
            return nil
        }
    }

    /// Подпись внутри радиального меню.
    var title: String {
        switch self {
        case .translateText: return "Text"
        case .translateScreenshot: return "Screenshot"
        case .askAI: return "Ask AI"
        case .grammar: return "Grammar"
        }
    }

    /// Заголовок окна инструмента.
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

/// Группа действий, которая в меню превращается в подменю.
enum AppActionGroup: String, CaseIterable, Identifiable {
    case translate

    var id: String { rawValue }

    var title: String { "Translate" }
    var icon: String { "character.bubble" }
    var color: Color { .purple }

    var actions: [AppAction] {
        AppAction.allCases.filter { $0.group == self }
    }
}
