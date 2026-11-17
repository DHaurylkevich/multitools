#if DEBUG
import Foundation
import SwiftUI


@MainActor
final class PreviewDispatcher: Translating, Explaining, GrammarChecking {
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
