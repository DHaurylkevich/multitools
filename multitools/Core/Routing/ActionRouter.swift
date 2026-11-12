import SwiftUI

/// Точка входа для запросов «открыть инструмент».
/// Контроллеры зависят от протокола, а не от конкретного роутера.
@MainActor
protocol ActionRouting: AnyObject {
    func open(_ action: AppAction)
}

/// Таблица маршрутов: преобразует действие в окно инструмента.
///
/// Роутер не управляет окнами (`WindowCoordinator`) и не показывает ошибки
/// (`AlertPresenting`) — он только связывает действие с экраном и сценарием.
@MainActor
final class ActionRouter: ActionRouting {
    private let dispatcher: any ActionDispatching
    private let windows: any WindowPresenting
    private let alerts: any AlertPresenting

    init(
        dispatcher: any ActionDispatching,
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
            size: CGSize(width: 520, height: 560),
            content: content,
            replaceExistingContent: replaceExistingContent
        )
    }
}
