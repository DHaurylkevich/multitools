import CoreGraphics
import Foundation
@preconcurrency import Vision

final class OCRService: TextRecognizing, Sendable {
    private static let recognitionLanguages = ["ru-RU", "en-US"]

    private static let textRecognitionRevision = VNRecognizeTextRequestRevision3

    /// Слова одной строки текста имеют разную высоту и центр по Y,
    /// поэтому строки группируются с допуском, а не сравниваются напрямую.
    private static let lineTolerance: CGFloat = 0.5

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
            request.recognitionLevel = .accurate
            request.recognitionLanguages = Self.recognitionLanguages
            request.automaticallyDetectsLanguage = true
            request.usesLanguageCorrection = true

            do {
                try VNImageRequestHandler(cgImage: image, options: [:]).perform([request])
            } catch {
                throw OCRError.recognitionFailed(error.localizedDescription)
            }

            guard let observations = request.results, !observations.isEmpty else {
                return ""
            }

            return Self.readingOrder(observations)
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: "\n")
        }.value
    }

    private static func readingOrder(
        _ observations: [VNRecognizedTextObservation]
    ) -> [VNRecognizedTextObservation] {
        let sorted = observations.sorted { lhs, rhs in
            lhs.boundingBox.midY > rhs.boundingBox.midY
        }

        var lines: [[VNRecognizedTextObservation]] = []
        for observation in sorted {
            let box = observation.boundingBox
            if let anchor = lines.last?.first?.boundingBox,
               abs(anchor.midY - box.midY) < min(anchor.height, box.height) * lineTolerance {
                lines[lines.count - 1].append(observation)
            } else {
                lines.append([observation])
            }
        }

        return lines.flatMap { line in
            line.sorted { $0.boundingBox.minX < $1.boundingBox.minX }
        }
    }
}
