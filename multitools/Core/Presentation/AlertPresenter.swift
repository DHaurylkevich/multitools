import AppKit

@MainActor
protocol AlertPresenting: AnyObject {
    func present(title: String, message: String)
}

@MainActor
final class ModalAlertPresenter: AlertPresenting {
    func present(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }
}
