import SwiftUI

private enum InputBarLayout {
    static let horizontalSpacing: CGFloat = 10
    static let verticalTextPadding: CGFloat = 4
    static let contentPadding: CGFloat = 12

    static let buttonSize: CGFloat = 26
    static let iconSize: CGFloat = 12
    static let iconScaleTransition: CGFloat = 0.7
    static let submitIcon = "arrow.right"

    static let minLines = 1
    static let maxLines = 6

    static let stateAnimation: Animation = .easeInOut(duration: 0.2)
    static let swapTransition: AnyTransition =
        .opacity.combined(with: .scale(scale: iconScaleTransition))
}

struct TextInputSection: View {
    @Binding var text: String

    let placeholder: String
    let isLoading: Bool
    var submitHelp: String = "Submit (Enter)"
    let onSubmit: () -> Void

    @FocusState private var isFocused: Bool

    private var canSubmit: Bool {
        !isLoading && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        HStack(alignment: .top, spacing: InputBarLayout.horizontalSpacing) {
            TextField(placeholder, text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(InputBarLayout.minLines...InputBarLayout.maxLines)
                .font(.system(size: PanelTokens.bodyFontSize))
                .padding(.vertical, InputBarLayout.verticalTextPadding)
                .focused($isFocused)
                .onKeyPress(keys: [.return]) { press in
                    guard !press.modifiers.contains(.shift) else { return .ignored }
                    handleSubmit()
                    return .handled
                }

            submitButton
        }
        .padding(InputBarLayout.contentPadding)
        .task {
            isFocused = true
        }
    }

    private var submitButton: some View {
        Button(action: handleSubmit) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .transition(InputBarLayout.swapTransition)
                } else {
                    Image(systemName: InputBarLayout.submitIcon)
                        .font(.system(size: InputBarLayout.iconSize, weight: .semibold))
                        .foregroundStyle(canSubmit ? .white : .secondary)
                        .transition(InputBarLayout.swapTransition)
                }
            }
            .frame(width: InputBarLayout.buttonSize, height: InputBarLayout.buttonSize)
            .background(
                Circle().fill(
                    canSubmit ? Color.accentColor : Color.primary.opacity(0.08)
                )
            )
            .animation(InputBarLayout.stateAnimation, value: isLoading)
            .animation(InputBarLayout.stateAnimation, value: canSubmit)
        }
        .buttonStyle(.plain)
        .disabled(!canSubmit)
        .keyboardShortcut(.return, modifiers: .command)
        .help(submitHelp)
    }

    private func handleSubmit() {
        guard canSubmit else { return }
        onSubmit()
    }
}
