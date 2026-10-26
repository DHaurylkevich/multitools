//
//  TextService.swift
//  multitools
//
//  Created by Mac on 25/10/2026.
//

import Foundation

struct TextService {
    private let aiProvider: any AIProviding
    
    init(aiProvider: any AIProviding){
        self.aiProvider = aiProvider
    }
    
    func translate(_ text: String, to language: TranslationLanguage) async throws -> String {
        let trimmedText = try validatedText(text)

        return try await aiProvider.generate(
            systemPrompt: """
            You are a precise and professional translation engine. 
            Your only task is to translate the provided text into \(language.rawValue).

            CRITICAL RULES:
            1. Return ONLY the direct translation. 
            2. Do not include any introductions, explanations, greetings, or notes.
            4. Maintain the original formatting, line breaks, and punctuation as closely as possible.
            5. If the source text is already in English, return it exactly as it is without changes.
            """,
            userPrompt: trimmedText
        )
    }
    
    func explain(_ text: String) async throws -> String {
        let trimmedText = try validatedText(text)

        return try await aiProvider.generate(
            systemPrompt: """
            You are a helpful assistant.
            Explain concepts clearly and accurately.
            Adapt the depth of your explanation to the question.
            Use examples when they help understanding.
            If the question is ambiguous, ask for clarification.
            Answer in the same language as the user's message.
            """,
            userPrompt: trimmedText
        )
    }
    
    private func validatedText(_ text: String) throws -> String {
        let trimmedText = text.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedText.isEmpty else {
            throw TextServiceError.emptyText
        }

        return trimmedText
    }

}

enum TextServiceError: LocalizedError {
    case emptyText

    var errorDescription: String? {
        switch self {
        case .emptyText:
            return "Enter text to translate."
        }
    }
}
