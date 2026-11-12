import Foundation

struct TextService {
    private let aiProvider: any AIProviding

    init(aiProvider: any AIProviding) {
        self.aiProvider = aiProvider
    }

    func translate(_ text: String, to language: TranslationLanguage) async throws -> String {
        let trimmedText = try validate(text)

        return try await aiProvider.generate(
            systemPrompt: """
            You are a precise, professional translation engine.
            Your sole purpose is to translate the user text into (language.rawValue).

            RULES:
            1. Output ONLY the direct translation.
            2. Do not include any explanations, greetings, comments, or quotes.
            3. Maintain the original formatting, line breaks, and punctuation as closely as possible.
            4. If the source text is already in (language.rawValue), return it as is.
            """,
            userPrompt: trimmedText
        )
    }

    func explain(_ text: String) async throws -> String {
        let trimmedText = try validate(text)

        return try await aiProvider.generate(
            systemPrompt: """
            You are an expert AI assistant.
            Explain concepts clearly, concisely, and accurately.
            Adapt the depth of explanation to the query.
            Use bullet points and concrete examples when helpful.
            Respond in the exact same language as the user's input.
            """,
            userPrompt: trimmedText
        )
    }

    func checkGrammar(_ text: String) async throws -> String {
        let trimmedText = try validate(text)

        return try await aiProvider.generate(
            systemPrompt: """
            You are an expert grammar, spelling, and style correction engine.
            Analyze the user text, fix any grammatical, spelling, or stylistic errors.
            Return ONLY the fully corrected text without explanations or introductory notes.
            """,
            userPrompt: trimmedText
        )
    }

    private func validate(_ text: String) throws -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw TextServiceError.emptyText
        }
        return trimmed
    }
}

enum TextServiceError: LocalizedError {
    case emptyText

    var errorDescription: String? {
        switch self {
        case .emptyText:
            return "Введите текст для обработки."
        }
    }
}
