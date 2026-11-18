import SwiftUI

struct SettingsView: View {
    private enum SettingsSection: String, CaseIterable, Identifiable {
        case ai = "AI"

        var id: Self { self }

        var icon: String {
            switch self {
            case .ai: return "sparkles"
            }
        }
    }

    private let settings: AISettings

    @State private var selectedSection: SettingsSection? = .ai
    @State private var model: String
    @State private var contextSize: Int
    @State private var maxTokens: Int
    @State private var temperature: Double
    @State private var keepAlive: AISettings.KeepAlive

    init(settings: AISettings = AISettings()) {
        self.settings = settings
        self._model = State(initialValue: settings.model)
        self._contextSize = State(initialValue: settings.contextSize)
        self._maxTokens = State(initialValue: settings.maxTokens)
        self._temperature = State(initialValue: settings.temperature)
        self._keepAlive = State(initialValue: settings.keepAlive)
    }

    var body: some View {
        NavigationSplitView {
            List(SettingsSection.allCases, selection: $selectedSection) { section in
                Label(section.rawValue, systemImage: section.icon)
                    .tag(section)
            }
            .navigationTitle("Multitools")
        } detail: {
            Group {
                switch selectedSection {
                case .ai:
                    aiSettings
                case .none:
                    Text("Select a section")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .frame(minWidth: 620, minHeight: 440)
    }

    private var aiSettings: some View {
        Form {
            Section("Local model") {
                TextField("Model", text: $model, prompt: Text(AISettings.defaultModel))
                    .onChange(of: model) {
                        settings.model = model
                    }

                Text("Ollama model used for translation, explanations and grammar checks. Leave empty to use the default.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Memory") {
                Stepper(
                    "Context window: \(contextSize) tokens",
                    value: $contextSize,
                    in: AISettings.contextSizeRange,
                    step: 512
                )
                .onChange(of: contextSize) {
                    settings.contextSize = contextSize
                }

                Picker("Free memory", selection: $keepAlive) {
                    ForEach(AISettings.KeepAlive.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .onChange(of: keepAlive) {
                    settings.keepAlive = keepAlive
                }

                Text("The model stays in RAM between requests. A smaller context window and unloading the model when idle noticeably reduce memory usage.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Generation") {
                Stepper(
                    "Max response length: \(maxTokens) tokens",
                    value: $maxTokens,
                    in: AISettings.maxTokensRange,
                    step: 64
                )
                .onChange(of: maxTokens) {
                    settings.maxTokens = maxTokens
                }

                HStack {
                    Text("Temperature: \(temperature.formatted(.number.precision(.fractionLength(1))))")
                    Slider(value: $temperature, in: AISettings.temperatureRange, step: 0.1)
                }
                .onChange(of: temperature) {
                    settings.temperature = temperature
                }
            }
        }
        .formStyle(.grouped)
    }
}

#if DEBUG
#Preview("Settings") {
    SettingsView()
        .frame(width: 620, height: 440)
}
#endif
