//
//  DonutSegment.swift
//  multitools
//
//  Created by Mac on 30/10/2026.
//

import SwiftUI

struct DonutSegment: Shape {

    let startAngle: Angle
    let endAngle: Angle
    let innerRadius: CGFloat

    func path(in rect: CGRect) -> Path {

        let center = CGPoint(
            x: rect.midX,
            y: rect.midY
        )

        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * self.innerRadius

        var path = Path()

        // Внешняя дуга
        path.addArc(
            center: center,
            radius: outerRadius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )

        path.addArc(
            center: center,
            radius: innerRadius,
            startAngle: endAngle,
            endAngle: startAngle,
            clockwise: true
        )

        path.closeSubpath()

        return path
    }
}
