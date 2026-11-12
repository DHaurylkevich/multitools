import SwiftUI

struct DonutSegment: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var innerRadius: CGFloat
    var gapAngle: Angle = .degrees(2)

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * innerRadius

        let s = startAngle + gapAngle / 2
        let e = endAngle - gapAngle / 2

        var path = Path()
        path.addArc(center: center, radius: outer, startAngle: s, endAngle: e, clockwise: false)
        path.addArc(center: center, radius: inner, startAngle: e, endAngle: s, clockwise: true)
        path.closeSubpath()
        return path
    }
}
