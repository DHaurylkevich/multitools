import Foundation

struct OllamaProvider: AIProviding {
    private let endpoint: URL
    private let model: String
    private let session: URLSession

    init(
        endpoint: URL = URL(string: "http://127.0.0.1:11434/api/chat")!,
        model: String = "gemma4:e2b-it-qat",
        session: URLSession = .shared
    ) {
        self.endpoint = endpoint
        self.model = model
        self.session = session
    }

    func generate(systemPrompt: String, userPrompt: String) async throws -> String {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60.0

        let body = ChatRequest(
            model: model,
            messages: [
                ChatMessage(role: "system", content: systemPrompt),
                ChatMessage(role: "user", content: userPrompt)
            ],
            stream: false,
            think: false
        )

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OllamaError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw OllamaError.serverError(httpResponse.statusCode)
        }

        let result = try JSONDecoder().decode(ChatResponse.self, from: data)
        return result.message.content
    }
}

private struct ChatRequest: Encodable {
    let model: String
    let messages: [ChatMessage]
    let stream: Bool
    let think: Bool
}

private struct ChatMessage: Codable {
    let role: String
    let content: String
}

private struct ChatResponse: Decodable {
    let message: ChatMessage
}

enum OllamaError: LocalizedError {
    case invalidResponse
    case serverError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Неверный ответ от локального сервера Ollama."
        case .serverError(let code):
            return "Ошибка Ollama сервера с кодом \(code). Убедитесь, что модель загружена."
        }
    }
}
