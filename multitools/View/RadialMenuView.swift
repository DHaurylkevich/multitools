//
//  RadialMenuView.swift
//  multitools
//
//  Created by Mac on 27/10/2026.
//

import SwiftUI

struct RadialMenuView: View {
        
    let onSelect: (RadialMenuAction) -> Void
    
    private let tools: [MenuTool] = [
        MenuTool(
            id: "translate",
            label: "Translate",
            icon: "character.bubble",
            color: .purple,
            action: .translate
        ),
        MenuTool(
            id: "askAI",
            label: "Ask AI",
            icon: "sparkles",
            color: .blue,
            action: .askAI
        )
    ]
    
    private let innerRadius: CGFloat = 0.4
    private let outerRadius: CGFloat = 95
    
    var body: some View {
        ZStack{
            
            ForEach(Array(tools.enumerated()), id: \.element.id) { index, tool in
                
                let segmentAngle = 360.0 / Double(tools.count)
                
                let startAngle = Double(index) * segmentAngle - 90
                let endAngle = startAngle + segmentAngle
                
                let middleAngle = (startAngle + endAngle) / 2
                
                let middleRadius = outerRadius * (1 + innerRadius) / 2
                
                Button {
                    onSelect(tool.action)
                } label: {
                    
                    ZStack {
                        
                        DonutSegment(
                            startAngle: .degrees(startAngle),
                            endAngle: .degrees(endAngle),
                            innerRadius: innerRadius
                        )
                        .fill(tool.color)
                        
                        Image(systemName: tool.icon)
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
