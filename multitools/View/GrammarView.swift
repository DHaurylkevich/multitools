import SwiftUI

struct GrammarView: View {
    let dispatcher: any ActionDispatching

    @State private var inputText = "She dont knows how to wrote Swift code."
    @State private var correctedText: String? = nil
    @State private var isChecking = false
    @State private var errorMessage: String?
    @State private var isCopied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Grammar Check", systemImage: "pencil.and.outline")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 6) {
                TextEditor(text: $inputText)
                    .font(.body)
                    .frame(minHeight: 110)
                    .padding(8)
                    .background(Color(nsColor: .textBackgroundColor).opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                HStack {
                    Text("⌘ + Enter для быстрой проверки")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Button {
                        Task { await checkGrammar() }
                    } label: {
                        if isChecking {
                            ProgressView().controlSize(.small)
                        } else {
                            Label("Проверить", systemImage: "sparkles")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.return, modifiers: [.command])
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isChecking)
                }
            }

            if let corrected = correctedText {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Исправленный вариант", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                            .foregroundStyle(.green)

                        Spacer()

                        Button("Применить") {
                            inputText = corrected
                            correctedText = nil
                        }
                        .buttonStyle(.bordered)

                        Button {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(corrected, forType: .string)
                            isCopied = true
                            Task {
                                try? await Task.sleep(for: DesignTokens.Feedback.copyConfirmation)
                                isCopied = false
                            }
                        } label: {
                            Label(isCopied ? "Скопировано" : "Копировать", systemImage: isCopied ? "checkmark" : "doc.on.doc")
                                .font(.caption)
                        }
                        .buttonStyle(.borderless)
                    }

                    ScrollView {
                        Text(corrected)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .textSelection(.enabled)
                    }
                    .frame(maxHeight: 160)
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.caption)
            }

            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(minWidth: 460, minHeight: correctedText != nil ? 480 : 260)
        .animation(DesignTokens.Feedback.resultAnimation, value: correctedText != nil)
    }

    @MainActor
    private func checkGrammar() async {
        isChecking = true
        errorMessage = nil
        defer { isChecking = false }

        do {
            correctedText = try await dispatcher.checkGrammar(inputText)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#if DEBUG
#Preview("Grammar") {
    GrammarView(dispatcher: PreviewDispatcher())
        .frame(
            width: DesignTokens.ToolWindow.defaultSize.width,
            height: DesignTokens.ToolWindow.defaultSize.height
        )
}

#Preview("Grammar — ошибка сервиса") {
    GrammarView(dispatcher: PreviewDispatcher(failing: true))
        .frame(
            width: DesignTokens.ToolWindow.defaultSize.width,
            height: DesignTokens.ToolWindow.defaultSize.height
        )
}
#endif

