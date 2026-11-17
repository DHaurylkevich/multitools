import AppKit
import ScreenCaptureKit

enum ScreenCaptureDefaults {
    /// Предел длинной стороны снимка в пикселях: OCR не нужен 5K-кадр,
    /// а уменьшение кадра напрямую ускоряет Vision и разгружает устройство.
    static let maxPixelDimension: CGFloat = 2000
}

@MainActor
final class ScreenService: ScreenCapturing {
    private let selector = RegionSelector()

    func captureInteractive() async throws -> CGImage {
        guard ScreenRecordingPermission.requestIfNeeded() else {
            throw ScreenCaptureError.permissionDenied
        }

        async let shareableContent = SCShareableContent.excludingDesktopWindows(
            false,
            onScreenWindowsOnly: true
        )

        guard let selection = await selector.selectRegion() else {
            _ = try? await shareableContent
            throw ScreenCaptureError.cancelled
        }

        let content: SCShareableContent
        do {
            content = try await shareableContent
        } catch {
            throw ScreenCaptureError.permissionDenied
        }

        return try await capture(selection, content: content)
    }

    private func capture(_ selection: NSRect, content: SCShareableContent) async throws -> CGImage {
        let cursor = NSPoint(x: selection.midX, y: selection.midY)

        guard let screen = CaptureGeometry.screen(containing: cursor) ?? NSScreen.main,
              let displayID = CaptureGeometry.displayID(of: screen),
              let display = content.displays.first(where: { $0.displayID == displayID }) else {
            throw ScreenCaptureError.failed("не найден экран выделенной области")
        }

        guard let region = CaptureGeometry.region(
            for: selection,
            screenFrame: screen.frame,
            pixelScale: CaptureGeometry.pixelScale(
                screenWidth: screen.frame.width,
                displayPixelWidth: display.width
            )
        ) else {
            throw ScreenCaptureError.failed("выделенная область вне экрана")
        }

        let outputSize = CaptureGeometry.outputSize(
            pixelWidth: region.pixelWidth,
            pixelHeight: region.pixelHeight,
            maxDimension: ScreenCaptureDefaults.maxPixelDimension
        )

        let configuration = SCStreamConfiguration()
        configuration.sourceRect = region.sourceRect
        configuration.width = outputSize.width
        configuration.height = outputSize.height
        // Размеры сохраняют пропорции области, поэтому масштабирование не искажает кадр.
        configuration.scalesToFit = true
        configuration.showsCursor = false

        let filter = SCContentFilter(
            display: display,
            excludingApplications: excludingSelf(from: content),
            exceptingWindows: []
        )

        do {
            return try await SCScreenshotManager.captureImage(
                contentFilter: filter,
                configuration: configuration
            )
        } catch {
            throw ScreenCaptureError.failed(error.localizedDescription)
        }
    }

    /// Исключаем само приложение из снимка: рамка выделения закрывается прямо
    /// перед захватом, и без исключения приходилось ждать, пока её уберёт композитор.
    private func excludingSelf(from content: SCShareableContent) -> [SCRunningApplication] {
        let processID = ProcessInfo.processInfo.processIdentifier
        return content.applications.filter { $0.processID == processID }
    }
}
