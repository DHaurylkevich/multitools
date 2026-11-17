import SwiftUI

struct ChatMessageItem: Identifiable, Equatable {
    let id = UUID()
    let isUser: Bool
    let text: String
}

private enum AskAIDesign {
    static let messageSpacing: CGFloat = 14
    static let bubbleCornerRadius: CGFloat = 12
    static let bubbleHorizontalPadding: CGFloat = 12
    static let bubbleVerticalPadding: CGFloat = 8
    static let bubbleInset: CGFloat = 40

    static let headerIconSize: CGFloat = 13
    static let headerButtonSize: CGFloat = 24

    static let userBubbleColor = Color.accentColor
    static let userBubbleTextColor = Color.white

    static let bottomAnchor = "conversation-bottom"

    static let messageTransition: AnyTransition = .asymmetric(
        insertion: .opacity.combined(with: .move(edge: .bottom)),
        removal: .opacity
    )
}

struct AskAIView: View {
    let explainer: any Explaining

    @State private var messages: [ChatMessageItem] = [
        ChatMessageItem(
            isUser: false,
            text: "Hi! I'm your built-in AI assistant. Ask anything — explain code or draft some text."
        )
    ]
    @State private var inputText = ""
    @State private var isProcessing = false

    private var hasConversation: Bool {
        messages.count > 1
    }

    var body: some View {
        VStack(spacing: 0) {
            TextInputSection(
                text: $inputText,
                placeholder: "Ask anything...",
                isLoading: isProcessing,
                submitHelp: "Send (Enter)",
                onSubmit: {
                    Task { await sendMessage() }
                }
            )
            Divider()
            
            conversation
        }
        .frame(width: PanelTokens.width)
        .background(PanelTokens.background)
        .animation(FeedbackTokens.resultAnimation, value: messages)
        .animation(FeedbackTokens.resultAnimation, value: isProcessing)
    }

    private var header: some View {
        HStack {
            Text("Ask AI")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            if hasConversation {
                Button {
                    messages.removeLast(messages.count - 1)
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: AskAIDesign.headerIconSize, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(width: AskAIDesign.headerButtonSize, height: AskAIDesign.headerButtonSize)
                }
                .buttonStyle(.plain)
                .help("Clear chat")
                .transition(.opacity)
            }
        }
        .padding(.horizontal, PanelTokens.contentPadding)
        .padding(.top, PanelTokens.topPadding)
    }

    private var conversation: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: AskAIDesign.messageSpacing) {
                    ForEach(messages) { message in
                        messageRow(message)
                            .id(message.id)
                            .transition(AskAIDesign.messageTransition)
                    }

                    if isProcessing {
                        typingIndicator
                    }

                    Color.clear
                        .frame(height: 1)
                        .id(AskAIDesign.bottomAnchor)
                }
                .padding(.horizontal, PanelTokens.contentPadding)
                .padding(.vertical, AskAIDesign.messageSpacing)
            }
            .onChange(of: messages) { scrollToBottom(proxy) }
            .onChange(of: isProcessing) { scrollToBottom(proxy) }
            .onAppear { scrollToBottom(proxy, animated: false) }
        }
    }

    private func messageRow(_ message: ChatMessageItem) -> some View {
        HStack(alignment: .top, spacing: 10) {
            if message.isUser {
                Spacer(minLength: AskAIDesign.bubbleInset)
            }

            if message.isUser {
                Text(message.text)
                    .font(.system(size: PanelTokens.bodyFontSize))
                    .foregroundStyle(AskAIDesign.userBubbleTextColor)
                    .padding(.horizontal, AskAIDesign.bubbleHorizontalPadding)
                    .padding(.vertical, AskAIDesign.bubbleVerticalPadding)
                    .background(
                        AskAIDesign.userBubbleColor,
                        in: RoundedRectangle(cornerRadius: AskAIDesign.bubbleCornerRadius, style: .continuous)
                    )
                    .textSelection(.enabled)
            } else {
                Text(message.text)
                    .font(.system(size: PanelTokens.bodyFontSize))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)

                CopyButton(text: message.text, help: "Copy message")
            }

            if !message.isUser {
                Spacer(minLength: AskAIDesign.bubbleInset)
            }
        }
    }

    private var typingIndicator: some View {
        HStack(spacing: 8) {
            ProgressView()
                .controlSize(.small)

            Text("Thinking…")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer(minLength: 0)
        }
        .transition(.opacity)
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy, animated: Bool = true) {
        guard animated else {
            proxy.scrollTo(AskAIDesign.bottomAnchor, anchor: .bottom)
            return
        }

        withAnimation(FeedbackTokens.resultAnimation) {
            proxy.scrollTo(AskAIDesign.bottomAnchor, anchor: .bottom)
        }
    }

    @MainActor
    private func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isProcessing else { return }

        messages.append(ChatMessageItem(isUser: true, text: text))
        inputText = ""
        isProcessing = true
        defer { isProcessing = false }

        do {
            messages.append(ChatMessageItem(isUser: false, text: try await explainer.explain(text)))
        } catch {
            messages.append(ChatMessageItem(isUser: false, text: "Error: \(error.localizedDescription)"))
        }
    }
}

#if DEBUG
#Preview("Ask AI") {
    AskAIView(explainer: PreviewDispatcher())
        .frame(
            width: ToolWindowTokens.defaultSize.width,
            height: ToolWindowTokens.defaultSize.height
        )
}

// Перед отправкой введите вопрос — ответит заглушка `PreviewDispatcher`.
#Preview("Ask AI — ошибка сервиса") {
    AskAIView(explainer: PreviewDispatcher(failing: true))
        .frame(
            width: ToolWindowTokens.defaultSize.width,
            height: ToolWindowTokens.defaultSize.height
        )
}
#endif
