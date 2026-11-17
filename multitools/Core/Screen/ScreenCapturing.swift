import CoreGraphics

@MainActor
protocol ScreenCapturing {
    func captureInteractive() async throws -> CGImage
}
