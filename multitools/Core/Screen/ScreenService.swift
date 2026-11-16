import AppKit
import ScreenCaptureKit

@MainActor
final class ScreenService {
    enum ScreenshotError: LocalizedError {
        case permissionDenied
        case userCancelled
        case captureFailed(String)

        var errorDescription: String? {
            switch self {
            case .permissionDenied:
                return "Приложению нужен доступ к записи экрана. Включите multitools в «Системные настройки» → «Конфиденциальность и безопасность» → «Запись экрана» и попробуйте снова."
            case .userCancelled:
                return "Захват экрана отменён."
            case .captureFailed(let reason):
                return "Не удалось сделать снимок экрана: \(reason)"
            }
        }
    }

    private let selector = RegionSelector()
    
    func captureInteractive() async throws -> CGImage {
        guard ensureScreenRecordingAccess() else {
            throw ScreenshotError.permissionDenied
        }

        async let shareableContent = SCShareableContent.excludingDesktopWindows(
            false,
            onScreenWindowsOnly: true
        )

        guard let selection = await selector.selectRegion() else {
            _ = try? await shareableContent
            throw ScreenshotError.userCancelled
        }

        try await Task.sleep(for: DesignTokens.Timing.hideBeforeCapture)

        let content: SCShareableContent
        do {
            content = try await shareableContent
        } catch {
            throw ScreenshotError.permissionDenied
        }

        return try await capture(selection, content: content)
    }

    private func ensureScreenRecordingAccess() -> Bool {
        if CGPreflightScreenCaptureAccess() {
            return true
        }

        return CGRequestScreenCaptureAccess()
    }

    private func capture(_ selection: NSRect, content: SCShareableContent) async throws -> CGImage {
        guard let screen = NSScreen.screens.first(where: {
            $0.frame.contains(NSPoint(x: selection.midX, y: selection.midY))
        }) ?? NSScreen.main,
        let displayID = screen.displayID,
        let display = content.displays.first(where: { $0.displayID == displayID }) else {
            throw ScreenshotError.captureFailed("не найден экран выделенной области")
        }

        let part = selection.intersection(screen.frame)
        guard part.width >= 1, part.height >= 1 else {
            throw ScreenshotError.captureFailed("выделенная область вне экрана")
        }

        let scale = screen.frame.width > 0 ? CGFloat(display.width) / screen.frame.width : 1

        let configuration = SCStreamConfiguration()
        configuration.sourceRect = CGRect(
            x: part.minX - screen.frame.minX,
            y: screen.frame.maxY - part.maxY,
            width: part.width,
            height: part.height
        )
        configuration.width = max(Int((part.width * scale).rounded()), 1)
        configuration.height = max(Int((part.height * scale).rounded()), 1)
        configuration.scalesToFit = false
        configuration.showsCursor = false

        let filter = SCContentFilter(display: display, excludingWindows: [])

        do {
            return try await SCScreenshotManager.captureImage(
                contentFilter: filter,
                configuration: configuration
            )
        } catch {
            throw ScreenshotError.captureFailed(error.localizedDescription)
        }
    }
}

private extension NSScreen {
    var displayID: CGDirectDisplayID? {
        (deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.uint32Value
    }
}
