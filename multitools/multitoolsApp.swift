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
        self.dispatcher = ActionDispatcher(screen: screen)
    }
    
    var body: some Scene {
        MenuBarExtra("multitools", systemImage: "circle.grid.2x2") {
            ContentView(dispatcher: dispatcher)
        }
        .menuBarExtraStyle(.window)
    }
}
