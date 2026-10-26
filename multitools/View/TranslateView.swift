//
//  TranslateView.swift
//  multitools
//
//  Created by Mac on 26/10/2026.
//

import SwiftUI

struct TranslateView: View {
    let dispatcher: ActionDispatcher

    @State private var inputText = ""
    @State private var result = ""
    @State private var errorMessage: String?
    @State private var isTranslating = false
    @State private var selectedLanguage: TranslationLanguage = .english

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Translate")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Enter the text you want to translate.")
                .foregroundStyle(.secondary)

            TextEditor(text: $inputText)
                .frame(minHeight: 140)
                .border(.secondary.opacity(0.3))

            Picker("Translate to", selection: $selectedLanguage) {
                ForEach(TranslationLanguage.allCases) { language in
                    Text(language.title)
                        .tag(language)
                }
            }

            Button {
                Task {
                    await translateText()
                }
            } label: {
                if isTranslating {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Label("Translate", systemImage: "translate")
                }
            }
            .disabled(
                inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || isTranslating
            )

            if !result.isEmpty {
                Divider()

                Text("Result")
                    .font(.headline)

                ScrollView {
                    Text(result)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
            }

            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    @MainActor
    private func translateText() async {
        isTranslating = true
        errorMessage = nil
        result = ""

        defer {
            isTranslating = false
        }

        do {
            result = try await dispatcher.translate(
                inputText,
                to: selectedLanguage
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
