import Foundation
import AppKit
@preconcurrency import Vision

final class OCRService: Sendable {
    
    enum OCRError: LocalizedError {
        case cgImageCreationFailed
        
        var errorDescription: String? {
            switch self {
            case .cgImageCreationFailed:
                return "Не удалось получить CGImage из картинки"
            }
        }
    }

    /// Распознает текст на изображении (полностью совместимо со Swift Concurrency)
    static func extractText(from image: NSImage) async throws -> String {
        // 1. Извлекаем CGImage (CGImage является Sendable, его безопасно передавать в Task)
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let cgImage = bitmap.cgImage else {
            throw OCRError.cgImageCreationFailed
        }
        
        // 2. Запускаем изолированную фоновую задачу
        return try await Task.detached(priority: .userInitiated) {
            // Создаем request и handler ПРЯМО ВНУТРИ фоновой задачи.
            // Так они не пересекают границы потоков, и ошибки захвата исчезают.
            let request = VNRecognizeTextRequest()
            request.revision = VNRecognizeTextRequestRevision3
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["ru-RU", "en-US"]
            request.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            // perform синхронно выполняет анализ на фоновом потоке
            try handler.perform([request])
            
            // Сразу после perform результаты уже записаны в request.results
            guard let observations = request.results, !observations.isEmpty else {
                return ""
            }
            
            let lines = observations.compactMap { $0.topCandidates(1).first?.string }
            return lines.joined(separator: "\n")
        }.value
    }
}
