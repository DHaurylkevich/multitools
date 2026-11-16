
import SwiftUI

private enum GrammarDesign {
    static let mainSpacing: CGFloat = 10
    static let windowPadding: CGFloat = 20

    static let minWindowWidth: CGFloat = 460
    static let minWindowHeight: CGFloat = 260
    static let expandedWindowHeight: CGFloat = 480

    static let inputMinHeight: CGFloat = 100
    static let inputPadding: CGFloat = 8
    static let inputCornerRadius: CGFloat = 8
    static let inputBackground = Color(nsColor: .textBackgroundColor)

    static let resultSpacing: CGFloat = 8
    static let resultPadding: CGFloat = 12
    static let resultCornerRadius: CGFloat = 8
    static let resultMaxHeight: CGFloat = 160
}

struct GrammarView: View {

    let dispatcher: any ActionPerforming

    @State private var inputText = "She dont knows how to wrote Swift code."
    @State private var correctedText: String? = nil
    @State private var isChecking = false
    @State private var errorMessage: String?
    @State private var isCopied = false


    var body: some View {
        VStack(alignment: .leading, spacing: GrammarDesign.mainSpacing) {

            WindowLabel(
                title: "Grammar Check",
                icon: "pencil.and.outline"
            )

            inputSection

            if let corrected = correctedText {
                resultSection(corrected)
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.caption)
            }

            Spacer(minLength: 0)
        }
        .padding(GrammarDesign.windowPadding)
        .frame(
            minWidth: GrammarDesign.minWindowWidth,
            minHeight: correctedText != nil
                ? GrammarDesign.expandedWindowHeight
                : GrammarDesign.minWindowHeight
        )
        .animation(
            DesignTokens.Feedback.resultAnimation,
            value: correctedText != nil
        )
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 0) {

            TextEditor(text: $inputText)
                .font(.body)
                .frame(minHeight: GrammarDesign.inputMinHeight)
                .padding(GrammarDesign.inputPadding)
                .background(GrammarDesign.inputBackground)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: GrammarDesign.inputCornerRadius
                    )
                )

            HStack {
                Text("⌘ + Enter для быстрой проверки")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    Task {
                        await checkGrammar()
                    }
                } label: {
                    if isChecking {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Label("Проверить", systemImage: "sparkles")
                    }
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return, modifiers: [.command])
                .disabled(
                    inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    || isChecking
                )
            }
        }
    }

    private func resultSection(_ corrected: String) -> some View {
        VStack(alignment: .leading, spacing: GrammarDesign.resultSpacing) {

            Divider()

            HStack {
                Label(
                    "Исправленный вариант",
                    systemImage: "checkmark.circle.fill"
                )
                .font(.headline)
                .foregroundStyle(.green)

                Spacer()

                Button("Применить") {
                    inputText = corrected
                    correctedText = nil
                }
                .buttonStyle(.bordered)

                Button {
                    copyResult(corrected)
                } label: {
                    Label(
                        isCopied ? "Скопировано" : "Копировать",
                        systemImage: isCopied ? "checkmark" : "doc.on.doc"
                    )
                    .font(.caption)
                }
                .buttonStyle(.borderless)
            }

            ScrollView {
                Text(corrected)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(GrammarDesign.resultPadding)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: GrammarDesign.resultCornerRadius
                        )
                    )
                    .textSelection(.enabled)
            }
            .frame(maxHeight: GrammarDesign.resultMaxHeight)
        }
    }

    private func copyResult(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)

        isCopied = true

        Task {
            try? await Task.sleep(
                for: DesignTokens.Feedback.copyConfirmation
            )
            isCopied = false
        }
    }

    @MainActor
    private func checkGrammar() async {
        isChecking = true
        errorMessage = nil

        defer {
            isChecking = false
        }

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
