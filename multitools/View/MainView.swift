//
//  MainView.swift
//  multitools
//
//  Created by Mac on 26/10/2026.
//

import SwiftUI

struct MainView: View {
    let dispatcher: ActionDispatcher
    
    private enum Section: String, CaseIterable, Identifiable {
        case translate = "Translate"
        case askAI = "Ask AI"
        case settings = "Settings"

        var id: Self { self }

        var icon: String {
            switch self {
            case .translate:
                return "translate"
            case .askAI:
                return "sparkles"
            case .settings:
                return "gearshape"
            }
        }
    }

    @State private var selectedSection: Section? = .translate

    var body: some View {
        NavigationSplitView {
            List(
                Section.allCases,
                selection: $selectedSection
            ) { section in
                Label(section.rawValue, systemImage: section.icon)
                    .tag(section)
            }
            .navigationTitle("Multitools")
        } detail: {
            switch selectedSection {
            case .translate:
                TranslateView(dispatcher: dispatcher)
            case .askAI:
                AskAIView(dispatcher: dispatcher)
            case .settings:
                Text("Settings")
            case .none:
                Text("Select a tool")
            }
        }
        .frame(minWidth: 600, minHeight: 400)
    }
}
