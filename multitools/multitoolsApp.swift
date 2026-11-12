import SwiftUI

@main
struct multitoolsApp: App {
    private let dispatcher: ActionDispatcher
    private let router: WindowRouter
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

        let router = WindowRouter(dispatcher: dispatcher)
        let radialController = RadialController(router: router)

        let hotKeyService = HotKeyService {
            Task { @MainActor in
                radialController.toggle()
            }
        }

        self.dispatcher = dispatcher
        self.router = router
        self.radialController = radialController
        self.hotKeyService = hotKeyService
    }

    var body: some Scene {
        MenuBarExtra("multitools", systemImage: "circle.grid.2x2") {
            MainView(dispatcher: dispatcher, router: router)
        }
        .menuBarExtraStyle(.window)
    }
}
