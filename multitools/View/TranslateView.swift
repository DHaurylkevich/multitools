import SwiftUI
import AppKit

struct TranslateView: View {
    let dispatcher: ActionDispatcher

    @State private var inputText: String
    @State private var result: String
    @State private var selectedLanguage: TranslationLanguage
    @State private var isTranslating = false
    @State private var errorMessage: String?
    @State private var isCopied = false

    private let autoTranslate: Bool

    init(
        dispatcher: ActionDispatcher,
        initialText: String = "",
        initialResult: String = "",
        initialLanguage: TranslationLanguage = .russian,
        autoTranslate: Bool = false
    ) {
        self.dispatcher = dispatcher
        self._inputText = State(initialValue: initialText)
        self._result = State(initialValue: initialResult)
        self._selectedLanguage = State(initialValue: initialLanguage)
        self.autoTranslate = autoTranslate || (!initialText.isEmpty && initialResult.isEmpty)
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
                .onChange(of: selectedLanguage) { _ in
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
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: hasResult)
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
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                self.result = res
            }
            adjustWindowSize(expanded: true)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        isCopied = true
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            isCopied = false
        }
    }

    private func adjustWindowSize(expanded: Bool) {
        guard let window = NSApp.keyWindow else { return }
        var frame = window.frame
        let targetHeight: CGFloat = expanded ? 500 : 260
        let delta = targetHeight - frame.size.height
        if abs(delta) > 10 {
            frame.origin.y -= delta
            frame.size.height = targetHeight
            window.animator().setFrame(frame, display: true)
        }
    }
}
