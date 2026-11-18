import SwiftUI

private enum InputBarLayout {
    static let horizontalSpacing: CGFloat = 10
    static let verticalTextPadding: CGFloat = 4
    static let contentPadding: CGFloat = 12

    static let buttonSize: CGFloat = 26
    static let iconSize: CGFloat = 12
    static let iconScaleTransition: CGFloat = 0.7
    static let submitIcon = "arrow.right"

    static let approximateLineHeight: CGFloat = 20
    static let minLines = 1
    static let maxLines = 10

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

    @State private var fieldHeight: CGFloat = 0

    private var canSubmit: Bool {
        !isLoading && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var visibleHeight: CGFloat {
        let minimum = CGFloat(InputBarLayout.minLines) * InputBarLayout.approximateLineHeight
        let maximum = CGFloat(InputBarLayout.maxLines) * InputBarLayout.approximateLineHeight
        return min(max(fieldHeight, minimum), maximum)
    }

    var body: some View {
        HStack(alignment: .top, spacing: InputBarLayout.horizontalSpacing) {
            ScrollView(.vertical) {
                TextField(placeholder, text: $text, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.system(size: PanelTokens.bodyFontSize))
                    .padding(.vertical, InputBarLayout.verticalTextPadding)
                    .focused($isFocused)
                    .onKeyPress(keys: [.return]) { press in
                        guard !press.modifiers.contains(.shift) else { return .ignored }
                        handleSubmit()
                        return .handled
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .background(
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: InputFieldHeightKey.self,
                                value: proxy.size.height
                            )
                        }
                    )
            }
            .frame(height: visibleHeight)
            .scrollDisabled(fieldHeight <= visibleHeight)
            .onPreferenceChange(InputFieldHeightKey.self) { height in
                fieldHeight = height
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

private struct InputFieldHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
