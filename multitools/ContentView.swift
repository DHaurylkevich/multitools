
import SwiftUI

struct ContentView: View {
    let dispatcher: ActionDispatcher

    @State private var inputTextToTranslate = ""
    @State private var inputTextToExplain = ""

    @State private var translationResult = ""
    @State private var explanationResult = ""

    @State private var translationError: String?
    @State private var explanationError: String?

    @State private var isTranslating = false
    @State private var isExplaining = false

    @State private var selectedLanguage: TranslationLanguage = .english

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Multitools")
                    .font(.title2)
                    .fontWeight(.semibold)

                translationSection

                Divider()

                explanationSection
            }
            .padding(24)
        }
        .frame(width: 340, height: 650)
    }

    private var translationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Translate text")
                .font(.headline)

            TextEditor(text: $inputTextToTranslate)
                .frame(height: 100)
                .border(.secondary.opacity(0.3))

            Picker("Translate to", selection: $selectedLanguage) {
                ForEach(TranslationLanguage.allCases) { language in
                    Text(language.title)
                        .tag(language)
                }
            }

            Button {
                Task {
                    await translateText()
                }
            } label: {
                if isTranslating {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Label("Translate", systemImage: "translate")
                }
            }
            .disabled(
                inputTextToTranslate.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty || isTranslating
            )

            if !translationResult.isEmpty {
                Text("Translation")
                    .font(.subheadline.weight(.semibold))

                Text(translationResult)
                    .textSelection(.enabled)
            }

            if let translationError {
                Text(translationError)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
            }
        }
    }

    private var explanationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ask AI")
                .font(.headline)

            TextEditor(text: $inputTextToExplain)
                .frame(height: 100)
                .border(.secondary.opacity(0.3))

            Button {
                Task {
                    await explainText()
                }
            } label: {
                if isExplaining {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Label("Explain", systemImage: "lightbulb")
                }
            }
            .disabled(
                inputTextToExplain.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty || isExplaining
            )

            if !explanationResult.isEmpty {
                Text("Answer")
                    .font(.subheadline.weight(.semibold))

                Text(explanationResult)
                    .textSelection(.enabled)
            }

            if let explanationError {
                Text(explanationError)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
            }
        }
    }

    @MainActor
    private func translateText() async {
        isTranslating = true
        translationError = nil
        translationResult = ""

        defer {
            isTranslating = false
        }

        do {
            translationResult = try await dispatcher.translate(
                inputTextToTranslate,
                to: selectedLanguage
            )
        } catch {
            translationError = error.localizedDescription
        }
    }

    @MainActor
    private func explainText() async {
        isExplaining = true
        explanationError = nil
        explanationResult = ""

        defer {
            isExplaining = false
        }

        do {
            explanationResult = try await dispatcher.explain(
                inputTextToExplain
            )
        } catch {
            explanationError = error.localizedDescription
        }
    }
}

#Preview {
    ContentView(
        dispatcher: ActionDispatcher(
            screen: ScreenService(),
            textService: TextService(
                aiProvider: OllamaProvider()
            )
        )
    )
}
