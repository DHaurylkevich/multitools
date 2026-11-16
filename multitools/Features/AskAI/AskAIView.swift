import SwiftUI

struct ChatMessageItem: Identifiable, Equatable {
    let id = UUID()
    let isUser: Bool
    let text: String
}

struct AskAIView: View {
    let dispatcher: any ActionPerforming

    @State private var messages: [ChatMessageItem] = [
        ChatMessageItem(
            isUser: false,
            text: "Привет! Я ваш встроенный AI ассистент. Задайте любой вопрос, попросите объяснить код или написать текст."
        )
    ]
    @State private var inputText = ""
    @State private var isProcessing = false
    @State private var copiedId: UUID? = nil

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Ask AI", systemImage: "sparkles")
                        .font(.title3)
                        .fontWeight(.semibold)

                    Spacer()

                    if messages.count > 1 {
                        Button("Очистить чат") {
                            messages = [messages[0]]
                        }
                        .font(.caption)
                        .buttonStyle(.borderless)
                    }
                }

                TextEditor(text: $inputText)
                    .font(.body)
                    .frame(minHeight: 95)
                    .padding(8)
                    .background(Color(nsColor: .textBackgroundColor).opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )

                HStack {
                    Text("⌘ + Enter для отправки")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Button {
                        Task { await sendMessage() }
                    } label: {
                        if isProcessing {
                            ProgressView().controlSize(.small)
                        } else {
                            Label("Спросить AI", systemImage: "arrow.right.circle.fill")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.return, modifiers: [.command])
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isProcessing)
                }
            }
            .padding(16)
            .background(Color(nsColor: .windowBackgroundColor))

            Divider()
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { msg in
                            messageBubble(msg)
                                .id(msg.id)
                        }

                        if isProcessing {
                            HStack {
                                Text("AI генерирует ответ...")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .padding(.leading, 8)
                            .id("typingIndicator")
                        }
                    }
                    .padding(16)
                }
                .onChange(of: messages) {
                    if let last = messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }
        }
        .frame(minWidth: 480, minHeight: 520)
    }

    private func messageBubble(_ msg: ChatMessageItem) -> some View {
        HStack {
            if msg.isUser { Spacer(minLength: 40) }

            VStack(alignment: msg.isUser ? .trailing : .leading, spacing: 4) {
                Text(msg.text)
                    .padding(10)
                    .foregroundStyle(msg.isUser ? .white : .primary)
                    .background(msg.isUser ? Color.blue : Color(nsColor: .controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .textSelection(.enabled)

                HStack(spacing: 6) {
                    Text(msg.isUser ? "Вы" : "AI")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    if !msg.isUser {
                        Button {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(msg.text, forType: .string)
                            copiedId = msg.id
                            Task {
                                try? await Task.sleep(for: DesignTokens.Feedback.copyConfirmation)
                                copiedId = nil
                            }
                        } label: {
                            Label(copiedId == msg.id ? "Скопировано" : "Копировать", systemImage: copiedId == msg.id ? "checkmark" : "doc.on.doc")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }

            if !msg.isUser { Spacer(minLength: 40) }
        }
    }

    @MainActor
    private func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        messages.append(ChatMessageItem(isUser: true, text: text))
        inputText = ""
        isProcessing = true
        defer { isProcessing = false }

        do {
            let answer = try await dispatcher.explain(text)
            messages.append(ChatMessageItem(isUser: false, text: answer))
        } catch {
            messages.append(ChatMessageItem(isUser: false, text: "Ошибка: \(error.localizedDescription)"))
        }
    }
}

#if DEBUG
#Preview("Ask AI") {
    AskAIView(dispatcher: PreviewDispatcher())
        .frame(
            width: DesignTokens.ToolWindow.defaultSize.width,
            height: DesignTokens.ToolWindow.defaultSize.height
        )
}

// Перед отправкой введите вопрос — ответит заглушка `PreviewDispatcher`.
#Preview("Ask AI — ошибка сервиса") {
    AskAIView(dispatcher: PreviewDispatcher(failing: true))
        .frame(
            width: DesignTokens.ToolWindow.defaultSize.width,
            height: DesignTokens.ToolWindow.defaultSize.height
        )
}
#endif

