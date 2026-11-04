struct ActionDispatcher {
    let screen: ScreenService
    let textService: TextService
    
    
    init(
        screen: ScreenService,
        textService: TextService
    ) {
        self.screen = screen
        self.textService = textService
    }
    
    func execute(_ action: MainMenuAction) -> String{
        switch action {
        case .screenCapture:
//            return screen.captureInteractive()
            return "screenshoot"
            
        case .translateText:
            return "Text translate"
        }
    }
    
    func translate(_ text: String, to language: TranslationLanguage) async throws ->String {
        try await textService.translate(text, to: language)
    }
    
    func explain(_ text: String) async throws ->String {
        try await textService.explain(text)
    }
}
