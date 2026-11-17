import SwiftUI

@MainActor
protocol FeatureViewMaking {
    func view(for action: AppAction) -> AnyView
    func translateView(initialText: String) -> AnyView
}

@MainActor
final class FeatureViewFactory: FeatureViewMaking {
    private let translator: any Translating
    private let explainer: any Explaining
    private let grammarChecker: any GrammarChecking

    init(
        translator: any Translating,
        explainer: any Explaining,
        grammarChecker: any GrammarChecking
    ) {
        self.translator = translator
        self.explainer = explainer
        self.grammarChecker = grammarChecker
    }

    func view(for action: AppAction) -> AnyView {
        switch action {
        case .translateText, .translateScreenshot:
            return AnyView(TranslateView(translator: translator, initialLanguage: .default))
        case .askAI:
            return AnyView(AskAIView(explainer: explainer))
        case .grammar:
            return AnyView(GrammarView(grammarChecker: grammarChecker))
        }
    }

    func translateView(initialText: String) -> AnyView {
        AnyView(TranslateView(translator: translator, initialText: initialText))
    }
}
