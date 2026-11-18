import Foundation

struct OllamaProvider: AIProviding {
    private let configuration: OllamaConfig
    private let settings: AISettings
    private let session: URLSession

    init(
        configuration: OllamaConfig = OllamaConfig(),
        settings: AISettings = AISettings(),
        session: URLSession = .shared
    ) {
        self.configuration = configuration
        self.settings = settings
        self.session = session
    }

    /// Загружает модель в память заранее: Ollama тратит несколько секунд на чтение модели
    /// с диска при первом запросе, а затем только считает токены.
    func preload() async {
        guard settings.keepAlive != .immediately else { return }

        var request = URLRequest(url: configuration.preloadEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = configuration.requestTimeout

        let body = PreloadRequest(
            model: settings.model,
            keepAlive: settings.keepAlive.rawValue,
            // Ollama перезагружает модель, если num_ctx в запросе отличается от загруженного,
            // поэтому прогрев обязан совпадать с реальным запросом.
            options: ChatOptions(
                numCtx: settings.contextSize,
                numPredict: settings.maxTokens,
                temperature: settings.temperature
            )
        )
        guard let encoded = try? JSONEncoder().encode(body) else { return }
        request.httpBody = encoded

        _ = try? await session.data(for: request)
    }

    func generate(systemPrompt: String, userPrompt: String) async throws -> String {
        var request = URLRequest(url: configuration.endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = configuration.requestTimeout

        let body = ChatRequest(
            model: settings.model,
            messages: [
                ChatMessage(role: "system", content: systemPrompt),
                ChatMessage(role: "user", content: userPrompt)
            ],
            stream: false,
            think: false,
            keepAlive: settings.keepAlive.rawValue,
            options: ChatOptions(
                numCtx: settings.contextSize,
                numPredict: settings.maxTokens,
                temperature: settings.temperature
            )
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

private struct PreloadRequest: Encodable {
    let model: String
    let stream: Bool = false
    let keepAlive: String
    let options: ChatOptions

    enum CodingKeys: String, CodingKey {
        case model, stream, options
        case keepAlive = "keep_alive"
    }
}

private struct ChatRequest: Encodable {
    let model: String
    let messages: [ChatMessage]
    let stream: Bool
    let think: Bool
    let keepAlive: String
    let options: ChatOptions

    enum CodingKeys: String, CodingKey {
        case model, messages, stream, think, options
        case keepAlive = "keep_alive"
    }
}

private struct ChatOptions: Encodable {
    let numCtx: Int
    let numPredict: Int
    let temperature: Double

    enum CodingKeys: String, CodingKey {
        case temperature
        case numCtx = "num_ctx"
        case numPredict = "num_predict"
    }
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
