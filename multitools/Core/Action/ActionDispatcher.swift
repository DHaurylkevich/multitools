//
//  ActionDispatcher.swift
//  multitools
//
//  Created by Mac on 25/10/2026.
//

struct ActionDispatcher {
    let screen: any ScreenCapturing
    let textService: TextService
    
    
    init(
        screen: any ScreenCapturing,
        textService: TextService
    ) {
        self.screen = screen
        self.textService = textService
    }
    
    func execute(_ action: ToolAction) -> String{
        switch action {
        case .screenCapture:
            return screen.capture()
            
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
