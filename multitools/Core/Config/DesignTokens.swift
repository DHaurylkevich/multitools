import SwiftUI

enum DesignTokens {

    enum RadialMenu {
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

        static let navigationAnimation: Animation =
            .easeInOut(duration: 0.15)

        static let backAnimation: Animation =
            .spring(response: 0.3, dampingFraction: 0.8)

        static let centerBorderOpacity: Double = 0.2
        static let centerHoverBorderOpacity: Double = 0.8
        static let centerBorderWidth: CGFloat = 1.5
        static let centerShadowRadius: CGFloat = 4

        static let backIconSize: CGFloat = 14
        static let closeIconSize: CGFloat = 12
        static let closeIconOpacity: Double = 0.45

    }
    
    enum RadialColors {
        static let segmentTop = Color(hex: "F5F5F5")
        static let segmentBottom = Color(hex: "E5E5E5")
        static let segmentHoverTop = Color(hex: "FFFFFF")
        static let segmentHoverBottom = Color(hex: "DADADA")
        static let icon = Color(hex: "383838")
    }

    enum ToolWindow {
        static let defaultSize: CGSize = CGSize(width: 520, height: 560)
    }

    enum Feedback {
        static let copyConfirmation: Duration = .milliseconds(1500)
        static let resultAnimation: Animation = .spring(response: 0.35, dampingFraction: 0.8)
    }

    enum Timing {
        static let hideBeforeCapture: Duration = .milliseconds(200)
    }
}
