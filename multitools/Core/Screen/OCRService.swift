import CoreGraphics
import Foundation
@preconcurrency import Vision

final class OCRService: TextRecognizing, Sendable {
    private static let recognitionLanguages = ["ru-RU", "en-US"]

    private static let textRecognitionRevision = VNRecognizeTextRequestRevision3

    enum OCRError: LocalizedError {
        case recognitionFailed(String)

        var errorDescription: String? {
            switch self {
            case .recognitionFailed(let message):
                return "Ошибка распознавания текста: \(message)"
            }
        }
    }

    func extractText(from image: CGImage) async throws -> String {
        try await Task.detached(priority: .userInitiated) {
            let request = VNRecognizeTextRequest()
            request.revision = Self.textRecognitionRevision
            // `.fast` хватает для экранного текста, а работает он в разы быстрее
            // `.accurate` при том же результате на чётком рендере.
            request.recognitionLevel = .fast
            request.recognitionLanguages = Self.recognitionLanguages
            request.usesLanguageCorrection = false

            do {
                try VNImageRequestHandler(cgImage: image, options: [:]).perform([request])
            } catch {
                throw OCRError.recognitionFailed(error.localizedDescription)
            }

            guard let observations = request.results, !observations.isEmpty else {
                return ""
            }

            return observations
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: "\n")
        }.value
    }
}
