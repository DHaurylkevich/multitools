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
    
    func translate(_ text: String) async throws -> String {
        try await aiProvider.generate(
            systemPromt: """
            You are a precise and professional translation engine. 
            Your only task is to translate the provided text into English accurately.

            CRITICAL RULES:
            1. Return ONLY the direct translation. 
            2. Do not include any introductions, explanations, greetings, or notes.
            3. Absolutely NO reasoning, thoughts, or chain-of-thought steps. D o not use <|think|> tags.
            4. Maintain the original formatting, line breaks, and punctuation as closely as possible.
            5. If the source text is already in English, return it exactly as it is without changes.

            """,

//            You are a translation
//            Translate the user's text into
//            Preserve the original meaning and tone.
//            Return only the translated text.

            userPromp: text
        )
    }
}
