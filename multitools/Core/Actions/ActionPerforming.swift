import Foundation

@MainActor
protocol ActionPerforming: AnyObject {
    func translate(_ text: String, to language: TranslationLanguage) async throws -> String
    func explain(_ text: String) async throws -> String
    func checkGrammar(_ text: String) async throws -> String
    func translateScreenshot(to language: TranslationLanguage) async throws -> ScreenshotTranslation
}
