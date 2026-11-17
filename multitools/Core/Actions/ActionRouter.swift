import SwiftUI

@MainActor
protocol ActionRouting: AnyObject {
    func open(_ action: AppAction)
}

@MainActor
final class ActionRouter: ActionRouting {
    private let views: any FeatureViewMaking
    private let windows: any WindowPresenting
    private let alerts: any AlertPresenting
    private let screenshotReader: any ScreenshotReading

    init(
        views: any FeatureViewMaking,
        windows: any WindowPresenting,
        alerts: any AlertPresenting,
        screenshotReader: any ScreenshotReading
    ) {
        self.views = views
        self.windows = windows
        self.alerts = alerts
        self.screenshotReader = screenshotReader
    }

    func open(_ action: AppAction) {
        switch action {
        case .translateScreenshot:
            openRecognizedScreenshotText()
        case .translateText, .askAI, .grammar:
            windows.present(window(for: action), content: views.view(for: action))
        }
    }

    /// Показывает распознанный текст в окне перевода. Перевод запускает сам
    /// пользователь, поэтому окно открывается сразу после OCR.
    private func openRecognizedScreenshotText() {
        Task { [weak self] in
            guard let self else { return }

            do {
                let text = try await screenshotReader.readTextFromScreenshot()
                windows.present(
                    window(for: .translateText, replaceExistingContent: true),
                    content: views.translateView(initialText: text)
                )
            } catch ScreenshotTextError.cancelled {
                // Пользователь сам отменил выбор области — это не ошибка.
            } catch {
                alerts.present(title: "Снимок экрана", message: error.localizedDescription)
            }
        }
    }

    private func window(for action: AppAction, replaceExistingContent: Bool = false) -> ToolWindow {
        ToolWindow(
            id: action.id,
            title: action.windowTitle,
            size: ToolWindowTokens.defaultSize,
            replaceExistingContent: replaceExistingContent
        )
    }
}
