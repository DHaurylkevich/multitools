import Foundation

/// Результат сценария «перевод со скриншота».
struct ScreenshotTranslation: Equatable {
    let recognizedText: String
    let translation: String
}

/// Возможности, которые нужны экранам приложения.
/// View зависят от протокола, а не от конкретного `ActionDispatcher`.
@MainActor
protocol ActionDispatching: AnyObject {
    func translate(_ text: String, to language: TranslationLanguage) async throws -> String
    func explain(_ text: String) async throws -> String
    func checkGrammar(_ text: String) async throws -> String
    func translateScreenshot(to language: TranslationLanguage) async throws -> ScreenshotTranslation
}
