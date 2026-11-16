#if DEBUG
import Foundation
import SwiftUI

/// Заглушка фасада действий для SwiftUI-превью.
///
/// В отличие от настоящего `ActionDispatcher` не ходит в Ollama и не
/// открывает захват экрана: возвращает предсказуемый текст через короткую
/// паузу, чтобы в Canvas были видны состояния загрузки и результата.
@MainActor
final class PreviewDispatcher: ActionDispatching {
    /// Если `true`, методы бросают ошибку — так проверяются состояния
    /// с сообщением об ошибке.
    private let failing: Bool

    init(failing: Bool = false) {
        self.failing = failing
    }

    func translate(_ text: String, to language: TranslationLanguage) async throws -> String {
        try await simulateWork()
        return "Перевод на \(language.title): «\(text)»"
    }

    func explain(_ text: String) async throws -> String {
        try await simulateWork()
        return "Пояснение к «\(text)». Это ответ заглушки: модель Ollama не вызывается, текст нужен только для проверки вёрстки."
    }

    func checkGrammar(_ text: String) async throws -> String {
        try await simulateWork()
        return "She doesn't know how to write Swift code."
    }

    func translateScreenshot(to language: TranslationLanguage) async throws -> ScreenshotTranslation {
        try await simulateWork()
        return ScreenshotTranslation(
            recognizedText: "Hello, world!",
            translation: "Привет, мир! (\(language.title))"
        )
    }

    private func simulateWork() async throws {
        try await Task.sleep(for: .milliseconds(150))
        if failing {
            throw PreviewError.simulated
        }
    }
}

enum PreviewError: LocalizedError {
    case simulated

    var errorDescription: String? {
        "Демонстрационная ошибка превью."
    }
}
#endif
