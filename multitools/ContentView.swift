//
//  ContentView.swift
//  multitools
//
//  Created by Mac on 24/10/2026.
//

import SwiftUI

struct ContentView: View {
    var dispatcher: ActionDispatcher
    
    @State private var inputText = ""
    @State private var result = ""
    @State private var isTranslating = false
    @State private var errorMessage: String?
    @State private var selectedLanguage: TranslationLanguage = .english
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16){
            Text("Multitools")
                .font(.title2)
            
            Text("Text to translate")
            
            TextEditor(text: $inputText)
                .frame(height: 100)
                .border(.secondary.opacity(0.3))
            
            Picker("Translate to", selection: $selectedLanguage) {
                ForEach(TranslationLanguage.allCases) { language in
                    Text(language.title)
                        .tag(language)
                }
            }
            
            Button{
                Task{await translateText()}
            } label: {
                if isTranslating {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Label("Translate to English", systemImage: "translate")
                }
            }
            .disabled(
                inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || isTranslating
            )

            if !result.isEmpty {
                Text("Translation")
                    .font(.headline)

                Text(result)
                    .textSelection(.enabled)
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
            }
        
            Button(action: {
                result = dispatcher.execute(.screenCapture)
            }){
                Label("Capture screen", systemImage: "viewfinder")
            }
            
            Button(action: {
                result = dispatcher.execute(.translateText)
            }){
                Label("Translate text", systemImage: "character.book.closed")
            }
            
            Button(action: {
                result = "Voice input"
            }) {
                Label("Voice input", systemImage: "waveform")
            }
        }
        .padding(24)
        .frame(width: 280)
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
                result = try await dispatcher.translate(inputText, to: selectedLanguage)
            } catch {
                errorMessage = "Translation failed: \(error.localizedDescription)"
            }
        }
    }

    #Preview {
        ContentView(
            dispatcher: ActionDispatcher(
                screen: ScreenService(),
                textService: TextService(
                    aiProvider: OllamaProvider()
                )
            )
        )
    }
