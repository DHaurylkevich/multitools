import SwiftUI

struct RadialMenuView: View {
    let rootItems: [RadialMenuItem]
    let onClose: () -> Void
    let onSelectAction: (AppAction) -> Void
    
    @State private var navigationStack: [[RadialMenuItem]] = []
    @State private var hoveredItemId: String? = nil
    
    private typealias Tokens = RadialMenuTokens
    
    private let innerRadiusRatio = Tokens.innerHoleRatio
    private let outerRadius = Tokens.outerRadius
    
    init(
        items: [RadialMenuItem],
        onClose: @escaping () -> Void = {},
        onSelectAction: @escaping (AppAction) -> Void
    ) {
        self.rootItems = items
        self.onClose = onClose
        self.onSelectAction = onSelectAction
    }
    
    private var currentItems: [RadialMenuItem] {
        navigationStack.last ?? rootItems
    }
    
    private func handleTap(for item: RadialMenuItem) {
        switch item.destination{
        case .submenu(let subItems):
            hoveredItemId = nil
            withAnimation(Tokens.navigationAnimation) {
                navigationStack.append(subItems)
            }
        case .action(let appAction):
            onSelectAction(appAction)
            onClose()
        }
    }
    
    private func handleCenterButtonTap() {
        if isSubmenuActive {
            withAnimation(Tokens.backAnimation) {
                _ = navigationStack.popLast()
            }
        } else {
            onClose()
        }
    }
    
    private var isSubmenuActive: Bool {
        !navigationStack.isEmpty
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .overlay {
                    Circle()
                        .strokeBorder(
                            Color.white.opacity(Tokens.ringBorderOpacity),
                            lineWidth: Tokens.ringBorderWidth
                        )
                }
            segmentsView
                .transition(.asymmetric(
                    insertion: .scale(scale: Tokens.levelEntryScale).combined(with: .opacity),
                    removal: .scale(scale: Tokens.levelExitScale).combined(with: .opacity)
                ))
            
            centerButton
        }
        .padding(Tokens.menuPadding)
        .frame(width: Tokens.menuDiameter, height: Tokens.menuDiameter)
        .animation(Tokens.navigationAnimation, value: navigationStack.count)
    }
    
    private var segmentsView: some View {
        ZStack {
            ForEach(Array(currentItems.enumerated()), id: \.element.id) { index, item in
                SegmentView(
                    
                    item: item,
                    index: index,
                    totalCount: currentItems.count,
                    outerRadius: outerRadius,
                    innerRadiusRatio: innerRadiusRatio,
                    isHovered: hoveredItemId == item.id,
                    onTap: {
                        handleTap(for: item)
                    },
                    onHoverChange: { isHovering in
                        if isHovering {
                            hoveredItemId = item.id
                        } else if hoveredItemId == item.id {
                            hoveredItemId = nil
                        }
                    }
                )
                
            }
        }
    }
    
    private var centerButton: some View {
        CenterButton(
            isSubmenuActive: isSubmenuActive,
            diameter: Tokens.centerButtonDiameter,
            onTap: handleCenterButtonTap
        )
    }
}

#Preview("Radial menu") {
    RadialMenuView(
        items: RadialMenuBuilder.rootItems,
        onSelectAction: { _ in }
    )
}
