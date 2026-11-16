import SwiftUI

private enum TextInputDesign {
    static let minHeight: CGFloat = 56
    static let maxHeight: CGFloat = 140
    static let buttonSize: CGFloat = 40
    static let spacing: CGFloat = 10
    static let padding: CGFloat = 8
    static let cornerRadius: CGFloat = 16
    static let animationDuration: Double = 0.2
}


struct TextInput: View {
    @Binding var text: String

    let placeholder: String
    let isLoading: Bool
    let onSubmit: () -> Void


    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(alignment: .center, spacing: TextInputDesign.spacing) {

            actionButton

            TextField(placeholder, text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...5)
                .focused($isFocused)
                .onKeyPress(.return) {
                    submit()
                    return .handled
                }
        }
        .padding(TextInputDesign.padding)
        .frame(minHeight: TextInputDesign.minHeight)
        .background(Color(nsColor: .textBackgroundColor))
        .clipShape(
            RoundedRectangle(
                cornerRadius: TextInputDesign.cornerRadius
            )
        )
        .onAppear {
            isFocused = true
        }
    }

    private var actionButton: some View {
        Button(action: submit) {
            ZStack {
                Image(systemName: "arrow.up")
                    .opacity(isLoading ? 0 : 1)

                ProgressView()
                    .controlSize(.small)
                    .opacity(isLoading ? 1 : 0)
            }
            .frame(
                width: TextInputDesign.buttonSize,
                height: TextInputDesign.buttonSize
            )
        }
        .buttonStyle(.borderedProminent)
        .clipShape(Circle())
        .disabled(isLoading || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .animation(
            .easeInOut(duration: TextInputDesign.animationDuration),
            value: isLoading
        )
    }

    private func submit() {
        guard !isLoading else { return }
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        onSubmit()
    }
}
