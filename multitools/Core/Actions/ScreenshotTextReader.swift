import CoreGraphics

@MainActor
final class ScreenshotTextReader: ScreenshotReading {
    private let screen: any ScreenCapturing
    private let ocr: any TextRecognizing

    init(screen: any ScreenCapturing, ocr: any TextRecognizing) {
        self.screen = screen
        self.ocr = ocr
    }

    func readTextFromScreenshot() async throws -> String {
        let screenshot: CGImage
        do {
            screenshot = try await screen.captureInteractive()
        } catch ScreenCaptureError.cancelled {
            throw ScreenshotTextError.cancelled
        }

        let recognizedText = try await ocr.extractText(from: screenshot)

        guard !recognizedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ScreenshotTextError.noTextFound
        }

        return recognizedText
    }
}
