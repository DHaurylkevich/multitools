import Foundation
import AppKit

@MainActor
final class ActionDispatcher {
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

    func translate(_ text: String, to language: TranslationLanguage = .english) async throws -> String {
        try await textService.translate(text, to: language)
    }

    func explain(_ text: String) async throws -> String {
        try await textService.explain(text)
    }

    func checkGrammar(_ text: String) async throws -> String {
        try await textService.checkGrammar(text)
    }

    func translateScreenshot(to language: TranslationLanguage = .english) async throws -> (recognizedText: String, translation: String) {
        let screenshot = try await screen.captureInteractive(hideApp: true, silent: true)

        let extractedText = try await ocr.extractText(from: screenshot)

        guard !extractedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DispatcherError.noTextFoundOnScreen
        }

        let translatedText = try await textService.translate(extractedText, to: language)
        return (extractedText, translatedText)
    }
}

enum DispatcherError: LocalizedError {
    case noTextFoundOnScreen
    case noTextSelected

    var errorDescription: String? {
        switch self {
        case .noTextFoundOnScreen:
            return "На снимке экрана не обнаружен читаемый текст."
        case .noTextSelected:
            return "Не удалось получить выделенный текст. Выделите фрагмент перед вызовом."
        }
    }
}
