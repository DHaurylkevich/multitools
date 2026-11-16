import SwiftUI

@MainActor
protocol ActionRouting: AnyObject {
    func open(_ action: AppAction)
}

@MainActor
final class ActionRouter: ActionRouting {
    private let dispatcher: any ActionPerforming
    private let windows: any WindowPresenting
    private let alerts: any AlertPresenting

    init(
        dispatcher: any ActionPerforming,
        windows: any WindowPresenting,
        alerts: any AlertPresenting
    ) {
        self.dispatcher = dispatcher
        self.windows = windows
        self.alerts = alerts
    }

    func open(_ action: AppAction) {
        switch action {
        case .translateText:
            windows.present(toolWindow(for: action, content: translateView()))
        case .translateScreenshot:
            translateScreenshot()
        case .askAI:
            windows.present(toolWindow(for: action, content: AnyView(AskAIView(dispatcher: dispatcher))))
        case .grammar:
            windows.present(toolWindow(for: action, content: AnyView(GrammarView(dispatcher: dispatcher))))
        }
    }

    private func translateScreenshot() {
        Task { [weak self] in
            guard let self else { return }

            do {
                let result = try await dispatcher.translateScreenshot(to: .default)
                windows.present(
                    toolWindow(
                        for: .translateText,
                        content: AnyView(
                            TranslateView(
                                dispatcher: dispatcher,
                                initialText: result.recognizedText,
                                initialResult: result.translation
                            )
                        ),
                        replaceExistingContent: true
                    )
                )
            } catch ScreenService.ScreenshotError.userCancelled {
                // Пользователь сам отменил выбор области — это не ошибка.
            } catch let error as ScreenService.ScreenshotError {
                alerts.present(title: "Снимок экрана", message: error.localizedDescription)
            } catch {
                alerts.present(title: "Ошибка распознавания", message: error.localizedDescription)
            }
        }
    }

    private func translateView() -> AnyView {
        AnyView(TranslateView(dispatcher: dispatcher, initialLanguage: .default))
    }

    private func toolWindow(
        for action: AppAction,
        content: AnyView,
        replaceExistingContent: Bool = false
    ) -> ToolWindow {
        ToolWindow(
            id: action.id,
            title: action.windowTitle,
            size: DesignTokens.ToolWindow.defaultSize,
            content: content,
            replaceExistingContent: replaceExistingContent
        )
    }
}
