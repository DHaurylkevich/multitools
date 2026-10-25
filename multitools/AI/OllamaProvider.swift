//
//  OllamaProvider.swift
//  multitools
//
//  Created by Mac on 25/10/2026.
//
import Foundation

struct OllamaProvider: AIProviding {
    private let endpoint = URL(
        string: "http://localhost:11434/api/chat"
    )!
    
    private let model = "gemma4:e2b-it-qat"
    
    
    func generate(systemPromt: String, userPromp: String) async throws -> String {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json",forHTTPHeaderField: "Content-Type")

        let body = ChatRequest(
            model: model,
            messages:[
                ChatMessages(role: "system", content: systemPromt),
                ChatMessages(role: "user", content: userPromp)
            ],
            stream: false
        )
        
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OllamaError.invalidResponse
        }
        
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw OllamaError.serverError(httpResponse.statusCode)
        }

        let result = try JSONDecoder().decode(
            ChatResponse.self,
            from: data
        )
        
        return result.message.content
    }
}

private struct ChatRequest: Encodable {
    let model: String
    let messages: [ChatMessages]
    let stream: Bool
}

private struct ChatMessages: Codable {
    let role: String
    let content: String
}

private struct ChatResponse: Decodable {
    let message: ChatMessages
}

enum OllamaError: Error {
    case invalidResponse
    case serverError(Int)
}

