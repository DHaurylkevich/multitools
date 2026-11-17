import Foundation

// Узкие контракты действий: каждый экран зависит ровно от той операции,
// которую использует, а не от всего списка возможностей.

protocol Translating {
    func translate(_ text: String, to language: TranslationLanguage) async throws -> String
}

protocol Explaining {
    func explain(_ text: String) async throws -> String
}

protocol GrammarChecking {
    func checkGrammar(_ text: String) async throws -> String
}

/// Чтение текста со снимка экрана: захват области и OCR без перевода.
@MainActor
protocol ScreenshotReading {
    func readTextFromScreenshot() async throws -> String
}
