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
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(scoreData.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // Score and chart
            HStack {
                // Score number
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(scoreData.score)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(colorForType(.primary))
                        
                        if scoreData.chartType == .arc {
                            Text("%")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(colorForType(.primary))
                        }
                    }
                }
                
                Spacer()
                
                // Chart
                chartView
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
        )
    }
    
    @ViewBuilder
    private var chartView: some View {
        switch scoreData.chartType {
        case .line:
            LineChartView()
                .frame(width: 80, height: 40)
        case .arc:
            ArcChartView(percentage: scoreData.score)
                .frame(width: 60, height: 60)
        }
    }
    
    private func colorForType(_ type: ColorType) -> Color {
        switch scoreData.color {
        case .green:
            return type == .primary ? .green : .mint
        case .blue:
            return type == .primary ? .blue : .cyan
        }
    }
    
    private enum ColorType {
        case primary, light
    }
}

struct LineChartView: View {
    var body: some View {
        Path { path in
            // 간단한 상승 곡선
            path.move(to: CGPoint(x: 0, y: 30))
            path.addCurve(
                to: CGPoint(x: 80, y: 5),
                control1: CGPoint(x: 30, y: 35),
                control2: CGPoint(x: 50, y: 15)
            )
        }
        .stroke(Color.green, lineWidth: 3)
        .clipped()
    }
}

struct ArcChartView: View {
    let percentage: Int
    
    var body: some View {
        ZStack {
            // Background arc
            Circle()
                .stroke(
                    Color.blue.opacity(0.2),
                    lineWidth: 6
                )
            
            // Progress arc
            Circle()
                .trim(from: 0, to: CGFloat(percentage) / 100.0 * 0.75) // 75% of circle
                .stroke(
                    Color.blue,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ScoreCard(scoreData: ScoreData(
            title: "Feeling Score",
            subtitle: "Points for speaking freely and confidently.",
            score: 85,
            color: .green,
            chartType: .line
        ))
        
        ScoreCard(scoreData: ScoreData(
            title: "Filling Score",
            subtitle: "Points for accuracy of the sentences.",
            score: 67,
            color: .blue,
            chartType: .arc
        ))
    }
    .padding()
}