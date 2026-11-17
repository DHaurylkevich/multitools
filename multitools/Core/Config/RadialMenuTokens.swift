import SwiftUI

enum RadialMenuTokens {
    static let outerRadius: CGFloat = 100
    static let innerHoleRatio: CGFloat = 0.38

    static let menuDiameter: CGFloat = (outerRadius * 2) * scaleEffectSegment

    static let scaleEffectSegment: CGFloat = 1.025

    static let centerButtonDiameter: CGFloat =
        outerRadius * innerHoleRatio * 2

    static let shadowMargin: CGFloat = 20

    static let panelSide: CGFloat =
        menuDiameter + shadowMargin * 2

    static let segmentGapAngle: Angle = .degrees(1.5)
    static let screenEdgeMargin: CGFloat = 8

    static let iconSize: CGFloat = 20

    static let levelEntryScale: CGFloat = 0.82
    static let levelExitScale: CGFloat = 0.12

    static let hoverDuration: Double = 0.15

    static let navigationAnimation: Animation = .easeInOut(duration: hoverDuration)
    static let hoverAnimation: Animation = .easeInOut(duration: hoverDuration)

    static let backAnimation: Animation =
        .spring(response: 0.3, dampingFraction: 0.8)

    static let centerBorderOpacity: Double = 0.2
    static let centerHoverBorderOpacity: Double = 0.8
    static let centerBorderWidth: CGFloat = 1.5
    static let centerShadowRadius: CGFloat = 4

    static let backIconSize: CGFloat = 14
    static let closeIconSize: CGFloat = 12
    static let closeIconOpacity: Double = 0.45

    static let menuPadding: CGFloat = 5
    static let ringBorderOpacity: Double = 0.8
    static let ringBorderWidth: CGFloat = 1

    static let segmentBorderOpacity: Double = 0.7
    static let segmentHoverBorderOpacity: Double = 0.95
    static let segmentBorderWidth: CGFloat = 0.8
    static let segmentHoverBorderWidth: CGFloat = 1.5
    static let iconHoverScale: CGFloat = 1.08
}

enum RadialColors {
    static let segmentTop = Color(hex: "F5F5F5")
    static let segmentBottom = Color(hex: "E5E5E5")
    static let segmentHoverTop = Color(hex: "FFFFFF")
    static let segmentHoverBottom = Color(hex: "DADADA")
    static let icon = Color(hex: "383838")
    static let centerButtonFill = Color(nsColor: .windowBackgroundColor)
}

private extension Color {
    /// Цвет из строки `RRGGBB`: используется только палитрой радиального меню.
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
