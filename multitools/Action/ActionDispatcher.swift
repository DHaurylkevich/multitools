//
//  ActionDispatcher.swift
//  multitools
//
//  Created by Mac on 25/10/2026.
//

struct ActionDispatcher {
    let screen: any ScreenCapturing
    let text: any TextTranslate
    
    init(screen: any ScreenCapturing) {
        self.screen = screen
        self.text = text
    }
    
    func execute(_ action: ToolAction) -> String{
        switch action {
        case .screenCapture:
            screen.capture()
        case .translateText:
            text.translate()
        }
    }
}
