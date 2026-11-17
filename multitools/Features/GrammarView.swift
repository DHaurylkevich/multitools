import SwiftUI

struct GrammarView: View {
    let grammarChecker: any GrammarChecking

    @State private var inputText = ""
    @State private var correctedText: String?
    @State private var isChecking = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextInputSection(
                text: $inputText,
                placeholder: "Enter text to check...",
                isLoading: isChecking,
                submitHelp: "Check grammar (Enter)",
                onSubmit: {
                    Task { await checkGrammar() }
                }
            )

            if let correctedText {
                OutputSection(text: correctedText)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal, PanelTokens.contentPadding)
                    .padding(.bottom, PanelTokens.errorBottomPadding)
                    .transition(.opacity)
            }
        }
        .frame(width: PanelTokens.width)
        .background(PanelTokens.background)
        .animation(FeedbackTokens.resultAnimation, value: correctedText)
        .animation(FeedbackTokens.resultAnimation, value: errorMessage)
    }

    @MainActor
    private func checkGrammar() async {
        guard !isChecking else { return }

        isChecking = true
        errorMessage = nil
        correctedText = nil

        defer { isChecking = false }

        do {
            correctedText = try await grammarChecker.checkGrammar(inputText)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#if DEBUG

#Preview("Grammar") {
    GrammarView(grammarChecker: PreviewDispatcher())
        .padding()
}

#Preview("Grammar — ошибка сервиса") {
    GrammarView(grammarChecker: PreviewDispatcher(failing: true))
        .padding()
}

#endif
