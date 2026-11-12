import SwiftUI

struct MainView: View {
    let dispatcher: ActionDispatcher
    let router: WindowRouter

    private enum Section: String, CaseIterable, Identifiable {
        case translate = "Translate"
        case askAI = "Ask AI"
        case settings = "Settings"

        var id: Self { self }

        var icon: String {
            switch self {
            case .translate: return "character.bubble" // "translate" не существует в SF Symbols!
            case .askAI: return "sparkles"
            case .settings: return "gearshape"
            }
        }
    }

    @State private var selectedSection: Section? = .translate

    var body: some View {
        NavigationSplitView {
            List(Section.allCases, selection: $selectedSection) { section in
                Label(section.rawValue, systemImage: section.icon)
                    .tag(section)
            }
            .navigationTitle("Multitools")
        } detail: {
            Group {
                switch selectedSection {
                case .translate:
                    TranslateView(dispatcher: dispatcher)
                case .askAI:
                    AskAIView(dispatcher: dispatcher)
                case .settings:
                    SettingsPlaceholderView()
                case .none:
                    Text("Выберите инструмент из бокового меню")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .frame(minWidth: 620, minHeight: 440)
    }
}

private struct SettingsPlaceholderView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "gearshape")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
            Text("Settings")
                .font(.title2)
                .fontWeight(.medium)
            Text("Горячая клавиша по умолчанию: ⌥ + F (Option + F)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
