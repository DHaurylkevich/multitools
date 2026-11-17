import AppKit
import SwiftUI

@MainActor
protocol WindowPresenting: AnyObject {
    func present(_ window: ToolWindow, content: AnyView)
}

@MainActor
final class WindowCoordinator: WindowPresenting {
    private var windows: [String: NSWindow] = [:]
    private var closeObservers: [String: NSObjectProtocol] = [:]

    func present(_ toolWindow: ToolWindow, content: AnyView) {
        if let existing = windows[toolWindow.id] {
            if toolWindow.replaceExistingContent {
                existing.contentViewController = NSHostingController(rootView: content)
            }
            NSApp.activate(ignoringOtherApps: true)
            existing.makeKeyAndOrderFront(nil)
            return
        }

        let window = makeWindow(toolWindow, content: content)
        windows[toolWindow.id] = window
        observeClose(of: window, id: toolWindow.id)

        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    private func makeWindow(_ toolWindow: ToolWindow, content: AnyView) -> NSWindow {
        let window = NSWindow(
            contentViewController: NSHostingController(rootView: content)
        )
        window.title = toolWindow.title
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
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
