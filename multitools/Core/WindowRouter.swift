import AppKit
import SwiftUI

@MainActor
final class WindowRouter {
    private let dispatcher: ActionDispatcher
    
    private var openWindows: [String: NSWindow] = [:]

    init(dispatcher: ActionDispatcher) {
        self.dispatcher = dispatcher
    }

    func open(_ action: AppAction) {
        switch action {
        case .translate(let subAction):
            handleTranslate(subAction)

        case .askAI:
            openWindow(id: "askAI", title: "Ask AI") {
                AskAIView(dispatcher: self.dispatcher)
            }

        case .grammar:
            openWindow(id: "grammar", title: "Grammar & Style Check") {
                GrammarView(dispatcher: self.dispatcher)
            }
        }
    }

    private func handleTranslate(_ subAction: TranslateAction) {
        switch subAction {
        case .text:
            openWindow(id: "translate", title: "Translate") {
                TranslateView(dispatcher: self.dispatcher)
            }

        case .screenshot:
            Task {
                do {
                    let result = try await dispatcher.translateScreenshot()
                    openWindow(id: "translate", title: "Translate") {
                        TranslateView(
                            dispatcher: self.dispatcher,
                            initialText: result.recognizedText,
                            initialResult: result.translation
                        )
                    }
                } catch {
                    presentAlert(title: "Ошибка распознавания", message: error.localizedDescription)
                }
            }

        }
    }

    private func openWindow<V: View>(id: String, title: String, size: NSSize = NSSize(width: 520, height: 560), @ViewBuilder content: () -> V) {
        if let existingWindow = openWindows[id], existingWindow.isVisible {
            NSApp.activate(ignoringOtherApps: true)
            existingWindow.makeKeyAndOrderFront(nil)
            return
        }

        let window = NSWindow(
            contentViewController: NSHostingController(rootView: content())
        )
        window.title = title
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.isReleasedWhenClosed = false
        window.setContentSize(size)
        window.center()

        openWindows[id] = window

        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    private func presentAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.runModal()
    }
}
