import SwiftUI

struct MainView: View {
    private enum Section: String, CaseIterable, Identifiable {
        case settings = "Settings"

        var id: Self { self }

        var icon: String {
            switch self {
            case .settings: return "gearshape"
            }
        }
    }

    @State private var selectedSection: Section? = .settings

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
            Text("Горячая клавиша по умолчанию: ⌥ + K (Option + K)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if DEBUG
#Preview("Main window") {
    MainView()
        .frame(width: 620, height: 440)
}
#endif

