import SwiftUI

struct DBWaveformView: View {
    var levels: [CGFloat]
    var minDB: CGFloat = -60
    var maxDB: CGFloat = -5
    var minBar: CGFloat = 10
    var maxBar: CGFloat = 60

    var body: some View {
        ZStack(alignment: .center) {
            GeometryReader { geo in
                let slice = Array(levels.suffix(24))
                HStack(alignment: .center, spacing: 10) {
                    ForEach(slice.indices, id: \.self) { i in
                        let db = slice[i]
                        let h = barHeight(for: db)
                        Capsule(style: .continuous)
                            .fill(.nmBackground3Pop)
                            .frame(width: 5, height: h)
                            .frame(height: maxBar, alignment: .center)
                            .offset(y: 0)
                            .accessibilityHidden(true)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                Rectangle()
                    .fill(.nmPointGreen1)
                    .frame(width: 1)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.trailing, 14)
            }
            .frame(height: 80)
        }
        .padding(.vertical, 12)
    }

    private func barHeight(for db: CGFloat) -> CGFloat {
        let clamped = max(min(db, maxDB), minDB)
        let t = (clamped - minDB) / (maxDB - minDB) // 0(low) ~ 1(high)
        return minBar + (maxBar - minBar) * t
    }
}
