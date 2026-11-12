import Foundation
import AppKit

@MainActor
final class ActionDispatcher: ActionDispatching {
    let screen: ScreenService
    let ocr: OCRService
    let textService: TextService

    init(
        screen: ScreenService? = nil,
        ocr: OCRService = OCRService(),
        textService: TextService
    ) {
        self.screen = screen ?? ScreenService()
        self.ocr = ocr
        self.textService = textService
    }

    func translate(_ text: String, to language: TranslationLanguage) async throws -> String {
        try await textService.translate(text, to: language)
    }

    func explain(_ text: String) async throws -> String {
        try await textService.explain(text)
    }

    func checkGrammar(_ text: String) async throws -> String {
        try await textService.checkGrammar(text)
    }

    func translateScreenshot(to language: TranslationLanguage) async throws -> ScreenshotTranslation {
        let screenshot = try await screen.captureInteractive(hideApp: true, silent: true)

        let extractedText = try await ocr.extractText(from: screenshot)

        guard !extractedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DispatcherError.noTextFoundOnScreen
        }

        let translatedText = try await textService.translate(extractedText, to: language)
        return ScreenshotTranslation(recognizedText: extractedText, translation: translatedText)
    }
}

enum DispatcherError: LocalizedError {
    case noTextFoundOnScreen

    var errorDescription: String? {
        switch self {
        case .noTextFoundOnScreen:
            return "На снимке экрана не обнаружен читаемый текст."
        }
    }
}
