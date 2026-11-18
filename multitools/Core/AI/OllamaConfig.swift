import Foundation

struct OllamaConfig {
    var endpoint: URL

    /// `/api/generate` без промпта только загружает модель в память.
    var preloadEndpoint: URL

    var requestTimeout: TimeInterval

    init(
        endpoint: URL = URL(string: "http://127.0.0.1:11434/api/chat")!,
        preloadEndpoint: URL = URL(string: "http://127.0.0.1:11434/api/generate")!,
        requestTimeout: TimeInterval = 60
    ) {
        self.endpoint = endpoint
        self.preloadEndpoint = preloadEndpoint
        self.requestTimeout = requestTimeout
    }
}
