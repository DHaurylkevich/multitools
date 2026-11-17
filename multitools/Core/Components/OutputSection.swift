import SwiftUI

private enum ResultLayout {
    static let contentPadding: CGFloat = 12
    static let spacing: CGFloat = 10
}

struct OutputSection: View {
    let text: String

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(alignment: .top, spacing: ResultLayout.spacing) {
                Text(text)
                    .font(.system(size: PanelTokens.bodyFontSize))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)

                CopyButton(text: text, help: "Copy result")
            }
            .padding(ResultLayout.contentPadding)
        }
    }
}
