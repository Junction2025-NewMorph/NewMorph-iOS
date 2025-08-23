import SwiftUI

struct DBWaveformView: View {
    var levels: [CGFloat]
    var visibleBars: Int = 28
    var barWidth: CGFloat = 6
    var spacing: CGFloat = 6
    var minDB: CGFloat = -60         
    var maxDB: CGFloat = -5
    var minBar: CGFloat = 6
    var maxBar: CGFloat = 36

    var body: some View {
        ZStack(alignment: .center) {
            GeometryReader { geo in
                let slice = Array(levels.suffix(visibleBars))

                HStack(alignment: .center, spacing: spacing) {
                    ForEach(slice.indices, id: \.self) { i in
                        let db = slice[i]
                        let h = barHeight(for: db)
                        Capsule(style: .continuous)
                            .fill(Color.primary.opacity(0.85))
                            .frame(width: barWidth, height: h)
                            .frame(height: maxBar, alignment: .center)
                            .offset(y: 0) // 센터 정렬
                            .accessibilityHidden(true)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.trailing, 28) // 커서 자리

                // 커서(민트)
                Rectangle()
                    .fill(Color(hue: 0.46, saturation: 0.74, brightness: 0.74))
                    .frame(width: 2)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.trailing, 14)
            }
            .frame(height: 40)
        }
        .padding(.vertical, 12)
        .accessibilityHidden(true)
    }

    private func barHeight(for db: CGFloat) -> CGFloat {
        // dB를 0~1 정규화 → 막대 높이
        let clamped = max(min(db, maxDB), minDB)
        let t = (clamped - minDB) / (maxDB - minDB) // 0(low) ~ 1(high)
        return minBar + (maxBar - minBar) * t
    }
}
