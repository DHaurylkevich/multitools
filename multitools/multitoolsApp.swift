//
//  multitoolsApp.swift
//  multitools
//
//  Created by Mac on 24/10/2026.
//

import SwiftUI

@main
struct multitoolsApp: App {
    private var dispatcher: ActionDispatcher
    
    init(){
        let screen = ScreenService()
        let aiProvider = OllamaProvider()
        let textService = TextService(aiProvider: aiProvider)

        self.dispatcher = ActionDispatcher(
            screen: screen,
            textService: textService
        )
    }
    
    var body: some Scene {
        MenuBarExtra("multitools", systemImage: "circle.grid.2x2") {
            MainView(dispatcher: dispatcher)
        }
        .menuBarExtraStyle(.window)
    }
}
