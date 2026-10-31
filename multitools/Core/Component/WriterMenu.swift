import SwiftUI

struct WriterMenu<Toolbar: View>: View {

    let title: String
    let actionTitle: String

    @Binding var input: String

    let response: String?
    let isLoading: Bool

    let onSubmit: () -> Void

    let toolbar: Toolbar

    var body: some View {
        VStack(spacing: 12) {

            Text(title)
                .font(.headline)

            toolbar

            TextEditor(text: $input)
                .frame(height: 100)

            Button(actionTitle, action: onSubmit)
                .disabled(input.isEmpty || isLoading)

            if isLoading {
                ProgressView()
            }

            if let response, !response.isEmpty {
                Divider()

                ScrollView {
                    Text(response)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .textSelection(.enabled)
                }
                .frame(maxHeight: 180)
            }
        }
        .padding()
        .frame(width: 320)
    }
}
