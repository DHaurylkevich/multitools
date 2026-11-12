import SwiftUI

@main
struct multitoolsApp: App {
    private let radialController: RadialController
    private let hotKeyService: HotKeyService

    init() {
        let screenService = ScreenService()
        let ocrService = OCRService()
        let aiProvider = OllamaProvider()
        let textService = TextService(aiProvider: aiProvider)

        let dispatcher = ActionDispatcher(
            screen: screenService,
            ocr: ocrService,
            textService: textService
        )

        let windows = WindowCoordinator()
        let router = ActionRouter(
            dispatcher: dispatcher,
            windows: windows,
            alerts: ModalAlertPresenter()
        )
        let radialController = RadialController(router: router)

        let hotKeyService = HotKeyService {
            Task { @MainActor in
                radialController.toggle()
            }
        }

        self.radialController = radialController
        self.hotKeyService = hotKeyService
    }

    var body: some Scene {
        MenuBarExtra("multitools", systemImage: "circle.grid.2x2") {
            MainView()
        }
        .menuBarExtraStyle(.window)
    }
}
