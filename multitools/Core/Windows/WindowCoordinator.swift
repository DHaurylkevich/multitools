import AppKit
import SwiftUI

/// Описание окна инструмента, которое умеет показать `WindowPresenting`.
struct ToolWindow {
    let id: String
    let title: String
    let size: CGSize
    let content: AnyView
    /// Заменить содержимое уже открытого окна (например, новым результатом).
    var replaceExistingContent: Bool = false
}

@MainActor
protocol WindowPresenting: AnyObject {
    func present(_ window: ToolWindow)
    func close(id: String)
}

/// Единственное место, которое знает, как создавать, переиспользовать
/// и закрывать окна инструментов. Ничего не знает о действиях и сервисах.
@MainActor
final class WindowCoordinator: WindowPresenting {
    private var windows: [String: NSWindow] = [:]
    private var closeObservers: [String: NSObjectProtocol] = [:]

    func present(_ toolWindow: ToolWindow) {
        if let existing = windows[toolWindow.id] {
            if toolWindow.replaceExistingContent {
                existing.contentViewController = NSHostingController(rootView: toolWindow.content)
            }
            NSApp.activate(ignoringOtherApps: true)
            existing.makeKeyAndOrderFront(nil)
            return
        }

        let window = makeWindow(toolWindow)
        windows[toolWindow.id] = window
        observeClose(of: window, id: toolWindow.id)

        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    func close(id: String) {
        windows[id]?.close()
    }

    private func makeWindow(_ toolWindow: ToolWindow) -> NSWindow {
        let window = NSWindow(
            contentViewController: NSHostingController(rootView: toolWindow.content)
        )
        window.title = toolWindow.title
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.isReleasedWhenClosed = false
        window.setContentSize(toolWindow.size)
        window.center()
        return window
    }

    private func observeClose(of window: NSWindow, id: String) {
        closeObservers[id] = NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.forget(id)
            }
        }
    }

    private func forget(_ id: String) {
        if let observer = closeObservers.removeValue(forKey: id) {
            NotificationCenter.default.removeObserver(observer)
        }
        windows.removeValue(forKey: id)
    }
}
