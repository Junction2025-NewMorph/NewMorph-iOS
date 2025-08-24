//
//  ScoreCard.swift
//  NewMorph-iOS
//
//  Created by OneThing on 8/23/25.
//

import SwiftUI

struct ScoreCard: View {
    let scoreData: ScoreData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title and subtitle
            VStack(alignment: .leading, spacing: 8) {
                Text(scoreData.title)
                    .font(.custom(FontName.pretendardBold.rawValue, size: 22))
                    .foregroundColor(.nmGrayscale1)
                
                Text(scoreData.subtitle)
                    .font(.custom(FontName.pretendardMedium.rawValue, size: 14))
                    .foregroundColor(.nmGrayscale4)
                    .lineLimit(2)
            }
            
            HStack(alignment: .bottom, spacing: 20) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(scoreData.score)")
                        .font(.custom(FontName.pretendardBold.rawValue, size: 32))
                        .foregroundColor(colorForType(.primary))

                    if scoreData.chartType == .arc {
                        Text("%")
                            .font(.custom(FontName.pretendardBold.rawValue, size: 20))
                            .foregroundColor(colorForType(.primary))
                    }
                }
                
                Spacer()
                
                // Chart
                chartView
            }
            
            // Detail scores
            VStack(alignment: .leading, spacing: 12) {
                ForEach(scoreData.details.indices, id: \.self) { index in
                    let detail = scoreData.details[index]
                    HStack {
                        Text(detail.category)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(detail.score)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.white))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
    
    @ViewBuilder
    private var chartView: some View {
        switch scoreData.chartType {
        case .line:
            LineChartView(strokeColor: colorForType(.primary))
                .frame(width: 180, height: 90)
        case .arc:
            SemiCircularGauge(value: Double(scoreData.score), color: colorForType(.primary))
                .frame(width: 150, height: 90)
                .scaleEffect(x: 1, y: -1)
                .offset(y: 80)
        }
    }
    
    private func colorForType(_ type: ColorType) -> Color {
        switch scoreData.color {
        case .green:
            return type == .primary ? Color("nmPointGreen1") : Color("nmPointGreen5")
        case .blue:
            return type == .primary ? Color("nmBlue") : Color("nmGrayscale5")
        }
    }
    
    private enum ColorType {
        case primary, light
    }
}

struct LineChartView: View {
    var strokeColor: Color = Color("nmPointGreen1")
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            // Preset normalized points (0~1) for gentle rising curve
            let points: [CGFloat] = [0.18, 0.22, 0.20, 0.34, 0.60, 0.78, 0.86]
            Path { path in
                for (i, v) in points.enumerated() {
                    let x = CGFloat(i) / CGFloat(points.count - 1) * w
                    let y = h - v * h
                    if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                    else { path.addLine(to: CGPoint(x: x, y: y)) }
                }
            }
            .stroke(strokeColor, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
        }
    }
}

// MARK: - Semi-circular gauge (animated, tire style)
struct SemiCircularGauge: View {
    var value: Double   // 0...100
    var lineWidth: CGFloat = 12
    var color: Color = Color("nmBlue")
    var track: Color = Color.gray.opacity(0.15)

    @State private var anim: CGFloat = 0

    var body: some View {
        ZStack {
            TopSemiCircleTrack()
                .stroke(track, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))

            TopSemiCircleProgress(progress: anim)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                anim = CGFloat(max(0, min(1, value/100)))
            }
        }
        .onChange(of: value) { _, v in
            withAnimation(.easeOut(duration: 0.6)) {
                anim = CGFloat(max(0, min(1, v/100)))
            }
        }
    }
}

// Shapes that compute center/radius from rect → avoids clipping/offset issues
private struct TopSemiCircleTrack: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let lineInset: CGFloat = 0
        let radius = min(rect.width/2, rect.height) - lineInset
        let center = CGPoint(x: rect.midX, y: rect.minY + (min(rect.width/2, rect.height) - lineInset))
        p.addArc(center: center,
                 radius: radius,
                 startAngle: .degrees(180),
                 endAngle: .degrees(0),
                 clockwise: true)
        return p
    }
}

private struct TopSemiCircleProgress: Shape {
    var progress: CGFloat // 0...1
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let lineInset: CGFloat = 0
        let radius = min(rect.width/2, rect.height) - lineInset
        let center = CGPoint(x: rect.midX, y: rect.minY + (min(rect.width/2, rect.height) - lineInset))
        let end = 180 - 180 * max(0, min(1, progress))
        p.addArc(center: center,
                 radius: radius,
                 startAngle: .degrees(180),
                 endAngle: .degrees(end),
                 clockwise: true)
        return p
    }
}

#Preview {
    VStack(spacing: 20) {
        ScoreCard(scoreData: ScoreData(
            title: "Feeling Score",
            subtitle: "Points for speaking freely and confidently.",
            score: 85,
            color: .green,
            chartType: .line,
            details: []
        ))
        
        ScoreCard(scoreData: ScoreData(
            title: "Filling Score",
            subtitle: "Points for accuracy of the sentences.",
            score: 67,
            color: .blue,
            chartType: .arc,
            details: []
        ))
    }
    .padding()
}
