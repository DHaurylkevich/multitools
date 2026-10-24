//
//  multitoolsApp.swift
//  multitools
//
//  Created by Mac on 24/10/2026.
//

import SwiftUI

@main
struct multitoolsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
