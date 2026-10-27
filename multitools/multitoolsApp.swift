//
//  multitoolsApp.swift
//  multitools
//
//  Created by Mac on 24/10/2026.
//

import SwiftUI

@main
struct multitoolsApp: App {
    private let dispatcher: ActionDispatcher
    private let floatingPanelControle: FloatingPanelController
    private let hotKeyService: HotKeyService
    
    init(){
        let screen = ScreenService()
        let aiProvider = OllamaProvider()
        let textService = TextService(aiProvider: aiProvider)

        let dispatcher = ActionDispatcher(
            screen: screen,
            textService: textService
        )
        
        let panelController = FloatingPanelController(
            dispatcher: dispatcher
        )
        
        self.dispatcher = dispatcher
        self.floatingPanelControle = panelController
        
        self.hotKeyService = HotKeyService{
            Task{ @MainActor in
                panelController.toggle()
            }
        }
    }
    
    var body: some Scene {
        MenuBarExtra("multitools", systemImage: "circle.grid.2x2") {
            MainView(dispatcher: dispatcher)
        }
        .menuBarExtraStyle(.window)
    }
}
