import SwiftUI

struct LanguageBar: View {
    @Binding var language: TranslationLanguage

    var body: some View {
        HStack(spacing: 8) {
            Text("Translate to:")
                .font(.caption)
                .foregroundStyle(.secondary)

            Picker("Translate to:", selection: $language) {
                ForEach(TranslationLanguage.allCases) { language in
                    Text(language.title).tag(language)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)
            .controlSize(.small)
            .fixedSize()

            Spacer(minLength: 0)
        }
        .padding(.horizontal, PanelTokens.contentPadding)
        .padding(.top, PanelTokens.topPadding)
    }
}
