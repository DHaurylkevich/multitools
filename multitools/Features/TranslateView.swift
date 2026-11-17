import SwiftUI

struct TranslateView: View {
    let translator: any Translating
    
    @State private var inputText: String
    @State private var result = ""
    @State private var selectedLanguage: TranslationLanguage
    @State private var isTranslating = false
    @State private var errorMessage: String?

    @State private var translateTask: Task<Void, Never>?

    init(
        translator: any Translating,
        initialText: String = "",
        initialLanguage: TranslationLanguage = .default
    ) {
        self.translator = translator
        self._inputText = State(initialValue: initialText)
        self._selectedLanguage = State(initialValue: initialLanguage)
    }

    private var hasResult: Bool {
        !result.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            LanguageBar(language: $selectedLanguage)
                .onChange(of: selectedLanguage) {
                    guard !inputText.isEmpty else { return }
                    
                    Task {
                        await translateText()
                    }
                }
            
            TextInputSection(
                text: $inputText,
                placeholder: "Enter text to translate...",
                isLoading: isTranslating,
                submitHelp: "Translate (Enter)",
                onSubmit: {
                    Task { await translateText() }
                }
            )
            
            if hasResult {
                OutputSection(text: result)
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
        .animation(FeedbackTokens.resultAnimation, value: hasResult)
        .animation(FeedbackTokens.resultAnimation, value: errorMessage)
    }


    @MainActor
    private func translateText() async {
        translateTask?.cancel()
        
        let task = Task { @MainActor in
            isTranslating = true
            errorMessage = nil
            defer { isTranslating = false }

            do {
                let value = try await translator.translate(inputText, to: selectedLanguage)

                guard !Task.isCancelled else { return }

                result = value
            } catch is CancellationError {
                return
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        translateTask = task
        await task.value
    }
}

#if DEBUG
#Preview("Translate — пустая форма") {
    TranslateView(translator: PreviewDispatcher())
        .frame(
            width: ToolWindowTokens.defaultSize.width,
            height: ToolWindowTokens.defaultSize.height
        )
}

#Preview("Translate — текст распознан со снимка") {
    TranslateView(
        translator: PreviewDispatcher(),
        initialText: "Hello, world!"
    )
    .frame(
        width: ToolWindowTokens.defaultSize.width,
        height: ToolWindowTokens.defaultSize.height
    )
}

#Preview("Translate — ошибка сервиса") {
    TranslateView(
        translator: PreviewDispatcher(failing: true),
        initialText: "Hello, world!"
    )
    .frame(
        width: ToolWindowTokens.defaultSize.width,
        height: ToolWindowTokens.defaultSize.height
    )
}
#endif
