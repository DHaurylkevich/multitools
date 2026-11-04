import SwiftUI

struct MainView: View {
    let dispatcher: ActionDispatcher
    
    private let screenService = ScreenService()
    
    @State private var recognizedText: String?
    @State private var capturedImage: NSImage?
    @State private var captureError: String?

    private func openScreenshot() {
        Task {
            self.captureError = nil

            do {
                // 1. Получаем картинку интерактивным скриншотом
                let image = try await screenService.captureInteractive(hideApp: true, silent: true)
                self.capturedImage = image
                
                // 2. Распознаем с нее текст через Vision
                self.recognizedText = try await OCRService.extractText(from: image)
//                print("Распознанный текст:\n\(self.recognizedText)")
                
                // 3. Дальше этот текст можно автоматически передать
                // в ваш TranslateView или AskAIView через dispatcher!
                
            } catch ScreenService.ScreenshotError.userCancelled {
                print("Отменено")
            } catch {
                self.captureError = error.localizedDescription
            }
        }
    }
    
    private enum Section: String, CaseIterable, Identifiable {
        case translate = "Translate"
        case askAI = "Ask AI"
        case settings = "Settings"

        var id: Self { self }

        var icon: String {
            switch self {
            case .translate: return "translate"
            case .askAI: return "sparkles"
            case .settings: return "gearshape"
            }
        }
    }

    @State private var selectedSection: Section? = .translate

    var body: some View {
        NavigationSplitView {
            List(
                Section.allCases,
                selection: $selectedSection
            ) { section in
                Label(section.rawValue, systemImage: section.icon)
                    .tag(section)
            }
            .navigationTitle("Multitools")
        } detail: {
            VStack(spacing: 16) {
                Button("Test Screenshot Selection") {
                    openScreenshot()
                }
                
                if let recognizedText {
                    Text(recognizedText)
                }
                
                if let capturedImage {
                    Image(nsImage: capturedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                }
                
                if let captureError {
                    Text(captureError)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
                
                Divider()
                
                switch selectedSection {
                case .translate:
                    TranslateView(dispatcher: dispatcher)
                case .askAI:
                    AskAIView(dispatcher: dispatcher)
                case .settings:
                    Text("Settings")
                case .none:
                    Text("Select a tool")
                }
            }
            .padding()
        }
        .frame(minWidth: 600, minHeight: 400)
    }
}
