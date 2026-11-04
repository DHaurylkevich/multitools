import Foundation

protocol AIProviding{
    func generate(
        systemPrompt: String,
        userPrompt: String
    ) async throws -> String
}
