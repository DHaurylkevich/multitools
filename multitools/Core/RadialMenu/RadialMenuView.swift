import SwiftUI

struct RadialMenuView: View {
    let onSelect: (RadialMenuAction) -> Void

    private let innerRadius: CGFloat = 0.4
    private let outerRadius: CGFloat = 95

    var body: some View {
        ZStack {
            ForEach(
                Array(RadialMenuAction.allCases.enumerated()),
                id: \.element
            ) { index, action in

                let segmentAngle = 360.0 / Double(RadialMenuAction.allCases.count)
                let startAngle = Double(index) * segmentAngle - 90
                let endAngle = startAngle + segmentAngle
                let middleAngle = (startAngle + endAngle) / 2
                let middleRadius = outerRadius * (1 + innerRadius) / 2

                Button {
                    onSelect(action)
                } label: {
                    ZStack {
                        DonutSegment(
                            startAngle: .degrees(startAngle),
                            endAngle: .degrees(endAngle),
                            innerRadius: innerRadius
                        )
                        .fill(action.color)

                        Image(systemName: action.icon)
                            .font(.system(size: 20))
                            .foregroundStyle(.white)
                            .offset(
                                x: middleRadius * cos(middleAngle * .pi / 180),
                                y: middleRadius * sin(middleAngle * .pi / 180)
                            )
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .frame(
            width: outerRadius * 2,
            height: outerRadius * 2
        )
    }
}
