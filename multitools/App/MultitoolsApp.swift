import SwiftUI

@main
struct MultitoolsApp: App {
    private let radialController: RadialController
    private let hotKeyService: HotKeyService

    init() {
        let aiProvider = OllamaProvider()
        let textService = TextService(aiProvider: aiProvider)

        let router = ActionRouter(
            views: FeatureViewFactory(
                translator: textService,
                explainer: textService,
                grammarChecker: textService
            ),
            windows: WindowCoordinator(),
            alerts: ModalAlertPresenter(),
            screenshotReader: ScreenshotTextReader(
                screen: ScreenService(),
                ocr: OCRService()
            )
        )

        let radialController = RadialController(router: router)

        let hotKeyService = HotKeyService {
            Task { await aiProvider.preload() }

            Task { @MainActor in
                radialController.toggle()
            }
        }

        self.radialController = radialController
        self.hotKeyService = hotKeyService
    }

    var body: some Scene {
        MenuBarExtra("multitools", systemImage: "circle.grid.2x2") {
            SettingsView()
        }
        .menuBarExtraStyle(.window)
    }
}
