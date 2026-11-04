import AppKit

@MainActor
struct ScreenService {
    enum ScreenshotError: LocalizedError {
        case userCancelled
        case clipboardReadFailed
        
        var errorDescription: String? {
            switch self {
            case .userCancelled:
                return "Захват отменен пользователем"
            case .clipboardReadFailed:
                return "Не удалось прочитать изображение из буфера"
            }
        }
    }
    
    /// Захватывает область экрана напрямую в буфер обмена и возвращает NSImage
    func captureInteractive(hideApp: Bool = true, silent: Bool = false) async throws -> NSImage {
        if hideApp {
            NSApp.hide(nil)
            try await Task.sleep(nanoseconds: 200_000_000)
        }
        
        defer {
            if hideApp {
                NSApp.unhide(nil)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
        
        let pasteboard = NSPasteboard.general
        let initialChangeCount = pasteboard.changeCount
        
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
