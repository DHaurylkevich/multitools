import SwiftUI

/// Кнопка копирования текста с подтверждением через галочку.
struct CopyButton: View {
    let text: String
    var help: String = "Copy"

    @State private var isCopied = false

    private enum Layout {
        static let iconSize: CGFloat = 13
        static let buttonSize: CGFloat = 24
        static let copyIcon = "doc.on.doc"
        static let copiedIcon = "checkmark"
        static let feedbackAnimation: Animation = .easeInOut(duration: 0.18)
    }

    var body: some View {
        Button(action: copy) {
            Image(systemName: isCopied ? Layout.copiedIcon : Layout.copyIcon)
                .font(.system(size: Layout.iconSize, weight: .medium))
                .foregroundStyle(isCopied ? .green : .secondary)
                .frame(width: Layout.buttonSize, height: Layout.buttonSize)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .help(help)
        .animation(Layout.feedbackAnimation, value: isCopied)
    }

    private func copy() {
        Clipboard.copy(text)
        isCopied = true

        Task {
            try? await Task.sleep(for: FeedbackTokens.copyConfirmation)
            isCopied = false
        }
    }
}
