import SwiftUI

struct RadialMenuView: View {
    let rootItems: [RadialMenuItem]
    let onClose: () -> Void
    let onSelectAction: (AppAction) -> Void

    @State private var navigationStack: [[RadialMenuItem]] = []
    @State private var hoveredItemId: String? = nil
    @State private var isCenterHovered = false

    private let innerRadiusRatio: CGFloat = 0.38
    private let outerRadius: CGFloat = 95

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

    private var isSubmenuActive: Bool {
        !navigationStack.isEmpty
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: outerRadius * 2, height: outerRadius * 2)

            segmentsView
                .id(navigationStack.count)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.82).combined(with: .opacity),
                    removal: .scale(scale: 1.12).combined(with: .opacity)
                ))

            centerButton
        }
        .frame(width: outerRadius * 2, height: outerRadius * 2)
        .animation(.spring(response: 0.32, dampingFraction: 0.78), value: navigationStack.count)
    }

    private var segmentsView: some View {
        ZStack {
            ForEach(Array(currentItems.enumerated()), id: \.element.id) { index, item in
                let count = Double(currentItems.count)
                let segmentAngle = 360.0 / count
                let startAngle = Double(index) * segmentAngle - 90
                let endAngle = startAngle + segmentAngle
                let middleAngle = (startAngle + endAngle) / 2
                let middleRadius = outerRadius * (1 + innerRadiusRatio) / 2
                let isHovered = hoveredItemId == item.id

                Button {
                    switch item.destination {
                    case .submenu(let sub):
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
                            navigationStack.append(sub)
                        }
                    case .action(let act):
                        onSelectAction(act)
                    }
                } label: {
                    ZStack {
                        DonutSegment(
                            startAngle: .degrees(startAngle),
                            endAngle: .degrees(endAngle),
                            innerRadius: innerRadiusRatio
                        )
                        .fill(item.color.opacity(isHovered ? 1.0 : 0.88))
                        .overlay(
                            DonutSegment(
                                startAngle: .degrees(startAngle),
                                endAngle: .degrees(endAngle),
                                innerRadius: innerRadiusRatio
                            )
                            .stroke(Color.white.opacity(isHovered ? 0.9 : 0.25), lineWidth: isHovered ? 2 : 1)
                        )
                        .scaleEffect(isHovered ? 1.03 : 1.0)

                        VStack(spacing: 2) {
                            Image(systemName: item.icon)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.white)

                            if case .submenu = item.destination {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 8))
                                    .foregroundStyle(.white.opacity(0.85))
                            }
                        }
                        .offset(
                            x: middleRadius * cos(middleAngle * .pi / 180),
                            y: middleRadius * sin(middleAngle * .pi / 180)
                        )
                    }
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    hoveredItemId = hovering ? item.id : nil
                }
            }
        }
    }

    private var centerButton: some View {
        Button {
            if isSubmenuActive {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    _ = navigationStack.popLast()
                }
            } else {
                onClose()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color(nsColor: .windowBackgroundColor))
                    .frame(width: outerRadius * innerRadiusRatio * 1.9, height: outerRadius * innerRadiusRatio * 1.9)
                    .overlay(
                        Circle()
                            .stroke(isCenterHovered ? Color.white.opacity(0.8) : Color.white.opacity(0.2), lineWidth: 1.5)
                    )
                    .shadow(radius: 4)

                if isSubmenuActive {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(isCenterHovered ? .primary : .secondary)
                } else {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.primary.opacity(isCenterHovered ? 1.0 : 0.45))
                }
            }
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isCenterHovered = hovering
        }
    }
}
