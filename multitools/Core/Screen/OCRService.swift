import Foundation
import AppKit
@preconcurrency import Vision

final class OCRService: Sendable {
    
    enum OCRError: LocalizedError {
        case cgImageCreationFailed
        case recognitionFailed(String)
        
        var errorDescription: String? {
            switch self {
            case .cgImageCreationFailed:
                return "Не удалось получить CGImage из снимка экрана."
            case .recognitionFailed(let message):
                return "Ошибка распознавания текста: \(message)"
            }
        }
    }

    func extractText(from image: NSImage) async throws -> String {
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let cgImage = bitmap.cgImage else {
            throw OCRError.cgImageCreationFailed
        }
        
        return try await Task.detached(priority: .userInitiated) {
            let request = VNRecognizeTextRequest()
            request.revision = VNRecognizeTextRequestRevision3
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["ru-RU", "en-US"]
            request.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            try handler.perform([request])
            
            guard let observations = request.results, !observations.isEmpty else {
                return ""
            }
            
            let lines = observations.compactMap { $0.topCandidates(1).first?.string }
            return lines.joined(separator: "\n")
        }.value
    }
}
