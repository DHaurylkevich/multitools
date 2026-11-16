import AppKit

@MainActor
final class ScreenService {
    enum ScreenshotError: LocalizedError {
        case userCancelled
        case clipboardReadFailed
        
        var errorDescription: String? {
            switch self {
            case .userCancelled:
                return "Захват экрана отменен пользователем (нажат Esc)"
            case .clipboardReadFailed:
                return "Не удалось прочитать изображение из буфера обмена"
            }
        }
    }
    
    func captureInteractive(hideApp: Bool = true, silent: Bool = true) async throws -> NSImage {
        if hideApp {
            NSApp.hide(nil)
            try await Task.sleep(for: DesignTokens.Timing.hideBeforeCapture)
        }
        
        defer {
            if hideApp {
                NSApp.unhide(nil)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
        
        let pasteboard = NSPasteboard.general
        let initialChangeCount = pasteboard.changeCount
        
        // -i — интерактивный выбор области мышью,
        // -c — сразу в буфер обмена, без файла на диске,
        // -x — без звука затвора.
        var arguments = ["-i", "-c"]
        if silent {
            arguments.append("-x")
        }
         
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.global(qos: .userInitiated).async {
                let task = Process()
                task.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
                task.arguments = arguments
                
                do {
                    try task.run()
                    task.waitUntilExit()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
        
        guard pasteboard.changeCount > initialChangeCount else {
            throw ScreenshotError.userCancelled
        }
        
        guard let image = NSImage(pasteboard: pasteboard) else {
            throw ScreenshotError.clipboardReadFailed
        }
        
        return image
    }
}
