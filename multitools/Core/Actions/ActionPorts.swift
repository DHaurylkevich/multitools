import Foundation

protocol Translating {
    func translate(_ text: String, to language: TranslationLanguage) async throws -> String
}

protocol Explaining {
    func explain(_ text: String) async throws -> String
}

protocol GrammarChecking {
    func checkGrammar(_ text: String) async throws -> String
}

@MainActor
protocol ScreenshotReading {
    func readTextFromScreenshot() async throws -> String
}
