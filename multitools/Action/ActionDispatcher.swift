//
//  ActionDispatcher.swift
//  multitools
//
//  Created by Mac on 25/10/2026.
//

struct ActionDispatcher {
    let screen: any ScreenCapturing
    
    init(screen: any ScreenCapturing) {
        self.screen = screen
    }
    
    func execute(_ action: ToolAction) -> String{
        switch action {
        case .screenCapture:
            screen.capture()
        }
        
    }
}
