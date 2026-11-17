import CoreGraphics

protocol TextRecognizing: Sendable {
    func extractText(from image: CGImage) async throws -> String
}
