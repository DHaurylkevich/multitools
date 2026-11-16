import SwiftUI

struct SegmentView: View {
    let item: RadialMenuItem
    let index: Int
    let totalCount: Int
    let outerRadius: CGFloat
    let innerRadiusRatio: CGFloat
    let isHovered: Bool
    
    private typealias Tokens = DesignTokens.RadialMenu
    private typealias TokensColors = DesignTokens.RadialColors
    
    let onTap: () -> Void
    let onHoverChange: (Bool) -> Void
    
    private var segmentAngle: Double { 360.0 / Double(totalCount) }
    private var startAngle: Double { Double(index) * segmentAngle - 90 }
    private var endAngle: Double { startAngle + segmentAngle }
    private var middleAngle: Double { (startAngle + endAngle) / 2 }
    private var middleRadius: CGFloat { outerRadius * (1 + innerRadiusRatio) / 2}
    
    private var segmentShape: DonutSegment {
        DonutSegment(
            startAngle: .degrees(startAngle),
            endAngle: .degrees(endAngle),
            innerRadiusRatio: innerRadiusRatio
        )
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                segmentShape
                    .fill(
                        LinearGradient(
                            colors: isHovered
                                ? [
                                    TokensColors.segmentHoverTop,
                                    TokensColors.segmentHoverBottom
                                ]
                                : [
                                    TokensColors.segmentTop,
                                    TokensColors.segmentBottom
                                ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        segmentShape
                            .stroke(
                                Color.white.opacity(isHovered ? 0.95 : 0.7),
                                lineWidth: isHovered ? 1.5 : 0.8
                            )
                    }
                    .scaleEffect(isHovered ? Tokens.scaleEffectSegment : 1)
                
                Image(systemName: item.icon)
                    .font(.system(size: Tokens.iconSize, weight: .medium))
                    .foregroundStyle(TokensColors.icon)
                    .scaleEffect(isHovered ? 1.08 : 1)
                    .offset(
                    x: middleRadius * cos(middleAngle * .pi / 180),
                    y: middleRadius * sin(middleAngle * .pi / 180)
                )
            }
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            onHoverChange(hovering)
        }
        .contentShape(segmentShape)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
    }
}

extension Color {
    init(hex: String) {
        let value = UInt64(hex, radix: 16) ?? 0

        self.init(
            .sRGB,
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255,
            opacity: 1
        )
    }
}
