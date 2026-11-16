import SwiftUI
import AppKit

struct TranslateView: View {
    let dispatcher: any ActionPerforming

    @State private var inputText: String
    @State private var result: String
    @State private var selectedLanguage: TranslationLanguage
    @State private var isTranslating = false
    @State private var errorMessage: String?
    @State private var isCopied = false

    private let autoTranslate: Bool

    init(
        dispatcher: any ActionPerforming,
        initialText: String = "",
        initialResult: String = "",
        initialLanguage: TranslationLanguage = .default
    ) {
        self.dispatcher = dispatcher
        self._inputText = State(initialValue: initialText)
        self._result = State(initialValue: initialResult)
        self._selectedLanguage = State(initialValue: initialLanguage)
        // Текст передан, но результата ещё нет — переводим сразу при появлении.
        self.autoTranslate = !initialText.isEmpty && initialResult.isEmpty
    }

    private var hasResult: Bool {
        !result.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Bar
            HStack {
                Label("Translate", systemImage: "character.bubble")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Picker("Перевести на:", selection: $selectedLanguage) {
                    ForEach(TranslationLanguage.allCases) { language in
                        Text(language.title).tag(language)
                    }
                }
                .frame(width: 150)
                .onChange(of: selectedLanguage) {
                    if !inputText.isEmpty {
                        Task { await translateText() }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                TextEditor(text: $inputText)
                    .font(.body)
                    .frame(minHeight: 110)
                    .padding(8)
                    .background(Color(nsColor: .textBackgroundColor).opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )

                HStack {
                    Text("⌘ + Enter для перевода")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Button {
                        Task { await translateText() }
                    } label: {
                        if isTranslating {
                            ProgressView().controlSize(.small)
                        } else {
                            Label("Перевести", systemImage: "arrow.right.circle.fill")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.return, modifiers: [.command])
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isTranslating)
                }
            }

            if hasResult {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Результат перевода", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Spacer()

                        Button {
                            copyToClipboard(result)
                        } label: {
                            Label(isCopied ? "Скопировано" : "Копировать", systemImage: isCopied ? "checkmark" : "doc.on.doc")
                                .font(.caption)
                        }
                        .buttonStyle(.borderless)
                    }

                    ScrollView {
                        Text(result)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                            .padding(12)
                            .background(Color(nsColor: .windowBackgroundColor).opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .frame(maxHeight: 180)
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity
                ))
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.caption)
            }

            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(minWidth: 460, minHeight: hasResult ? 480 : 250)
        .animation(DesignTokens.Feedback.resultAnimation, value: hasResult)
        .onAppear {
            if autoTranslate && !inputText.isEmpty && result.isEmpty {
                Task { await translateText() }
            }
        }
    }

    @MainActor
    private func translateText() async {
        isTranslating = true
        errorMessage = nil
        defer { isTranslating = false }

        do {
            let res = try await dispatcher.translate(inputText, to: selectedLanguage)
            withAnimation(DesignTokens.Feedback.resultAnimation) {
                self.result = res
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        isCopied = true
        Task {
            try? await Task.sleep(for: DesignTokens.Feedback.copyConfirmation)
            isCopied = false
        }
    }

}

#if DEBUG
// Превью работают на заглушке `PreviewDispatcher`: сеть и захват экрана
// не нужны, поэтому Canvas обновляется без запуска приложения.
#Preview("Translate — пустая форма") {
    TranslateView(dispatcher: PreviewDispatcher())
        .frame(
            width: DesignTokens.ToolWindow.defaultSize.width,
            height: DesignTokens.ToolWindow.defaultSize.height
        )
}

#Preview("Translate — с результатом") {
    TranslateView(
        dispatcher: PreviewDispatcher(),
        initialText: "Hello, world!",
        initialResult: "Привет, мир!",
        initialLanguage: .russian
    )
    .frame(
        width: DesignTokens.ToolWindow.defaultSize.width,
        height: DesignTokens.ToolWindow.defaultSize.height
    )
}

#Preview("Translate — ошибка сервиса") {
    TranslateView(
        dispatcher: PreviewDispatcher(failing: true),
        initialText: "Hello, world!"
    )
    .frame(
        width: DesignTokens.ToolWindow.defaultSize.width,
        height: DesignTokens.ToolWindow.defaultSize.height
    )
}
#endif

