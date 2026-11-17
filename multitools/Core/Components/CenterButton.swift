import SwiftUI

struct CenterButton: View {
    let isSubmenuActive: Bool
    let diameter: CGFloat
    let onTap: () -> Void
    
    @State private var isHovered = false

    private typealias Tokens = RadialMenuTokens
    private typealias TokensColors = RadialColors

    private var iconName: String {
            isSubmenuActive ? "arrow.uturn.backward" : "xmark"
        }

        private var iconSize: CGFloat {
            isSubmenuActive ? Tokens.backIconSize : Tokens.closeIconSize
        }

        private var iconColor: Color {
            if isSubmenuActive {
                return isHovered ? .primary : .secondary
            }

            return Color.primary.opacity(
                isHovered ? 1.0 : Tokens.closeIconOpacity
            )
        }

        private var borderOpacity: Double {
            isHovered
                ? Tokens.centerHoverBorderOpacity
                : Tokens.centerBorderOpacity
        }

        var body: some View {
            Button(action: onTap) {
                ZStack {
                    Circle()
                        .fill(TokensColors.centerButtonFill)
                        .frame(width: diameter, height: diameter)
                        .overlay {
                            Circle()
                                .stroke(
                                    Color.white.opacity(borderOpacity),
                                    lineWidth: Tokens.centerBorderWidth
                                )
                        }
                        .shadow(radius: Tokens.centerShadowRadius)

                    Image(systemName: iconName)
                        .font(.system(size: iconSize, weight: .bold))
                        .foregroundStyle(iconColor)
                }
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                withAnimation(Tokens.hoverAnimation) {
                    isHovered = hovering
                }
            }
            .contentShape(Circle())
        }
    }
