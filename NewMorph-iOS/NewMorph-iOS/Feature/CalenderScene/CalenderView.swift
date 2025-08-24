//
//  CalenderView.swift
//  NewMorph-iOS
//
//  Created by mini on 8/23/25.
//

import SwiftUI

struct CalenderView: View {
    @State private var revealed: Set<Int> = [0, 1, 2, 3, 4,5,6,7,8,9,10]

    private let rows = 5
    private let cols = 7

    var body: some View {
        GeometryReader { geo in
            let totalW = geo.size.width
            let totalSpacing = 9 * CGFloat(cols - 1)
            let cellW = (totalW - totalSpacing) / CGFloat(cols)
            let cellH = cellW
            let gridH = CGFloat(rows) * cellH + CGFloat(rows - 1) * 9

            ZStack {
                gridBase(cellSize: CGSize(width: cellW, height: cellH))

                Image(.imgCalender)
                    .resizable()
                    .scaledToFill()
                    .frame(width: totalW, height: gridH)
                    .clipped()
                    .mask(
                        SelectedCellsMask(
                            rows: rows, cols: cols,
                            cellSize: CGSize(width: cellW, height: cellH),
                            spacing: 9,
                            corner: 4,
                            revealed: revealed
                        )
                    )

                hitOverlay(cellSize: CGSize(width: cellW, height: cellH)) { idx in
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        if revealed.contains(idx) { revealed.remove(idx) }
                        else { revealed.insert(idx) }
                    }
                }
            }
            .frame(height: gridH)
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .background(.nmBackground1Main)
        .ignoresSafeArea(.all)
    }
}

// MARK: - 바닥 그리드
private extension CalenderView {
    @ViewBuilder
    func gridBase(cellSize: CGSize) -> some View {
        VStack(spacing: 9) {
            ForEach(0..<rows, id: \.self) { _ in
                HStack(spacing: 9) {
                    ForEach(0..<cols, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(.nmBackground2Modal)
                            .frame(width: cellSize.width, height: cellSize.height)
                    }
                }
            }
        }
    }

    func hitOverlay(
        cellSize: CGSize,
        onTap: @escaping (Int) -> Void
    ) -> some View {
        VStack(spacing: 9) {
            ForEach(0..<rows, id: \.self) { r in
                HStack(spacing: 9) {
                    ForEach(0..<cols, id: \.self) { c in
                        let idx = r * cols + c
                        Color.clear
                            .contentShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                            .frame(width: cellSize.width, height: cellSize.height)
                            .onTapGesture { onTap(idx) }
                    }
                }
            }
        }
        .allowsHitTesting(true)
    }
}

private struct SelectedCellsMask: View {
    let rows: Int
    let cols: Int
    let cellSize: CGSize
    let spacing: CGFloat
    let corner: CGFloat
    let revealed: Set<Int>

    var body: some View {
        Canvas { ctx, _ in
            var p = Path()
            for idx in revealed {
                guard idx >= 0 && idx < rows * cols else { continue }
                let r = idx / cols
                let c = idx % cols
                let x = CGFloat(c) * (cellSize.width + spacing)
                let y = CGFloat(r) * (cellSize.height + spacing)
                let rect = CGRect(origin: CGPoint(x: x, y: y), size: cellSize)
                p.addRoundedRect(in: rect, cornerSize: CGSize(width: corner, height: corner))
            }
            ctx.fill(p, with: .color(.black))
        }
    }
}

#Preview {
    CalenderView()
}
