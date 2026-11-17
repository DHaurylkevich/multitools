import Foundation

struct OllamaConfig {
    var endpoint: URL

    var model: String

    var requestTimeout: TimeInterval

    init(
        endpoint: URL = URL(string: "http://127.0.0.1:11434/api/chat")!,
        model: String = "gemma4:e2b-it-qat",
        requestTimeout: TimeInterval = 60
    ) {
        self.endpoint = endpoint
        self.model = model
        self.requestTimeout = requestTimeout
    }
}
