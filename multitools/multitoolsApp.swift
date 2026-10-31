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
    private let radialControle: RadialController
    private let hotKeyService: HotKeyService
    
    
    init(){
        let screen = ScreenService()
        let aiProvider = OllamaProvider()
        let textService = TextService(aiProvider: aiProvider)

        let dispatcher = ActionDispatcher(
            screen: screen,
            textService: textService
        )
        
        let router = WindowRouter(dispatcher: dispatcher)
        let radialControle = RadialController(
            router: router
        )
        
        self.dispatcher = dispatcher
        self.radialControle = radialControle
        
        self.hotKeyService = HotKeyService{
            Task{ @MainActor in
                radialControle.toggle()
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
