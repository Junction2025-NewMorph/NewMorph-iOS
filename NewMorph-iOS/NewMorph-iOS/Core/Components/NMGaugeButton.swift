import SwiftUI

struct NMGaugeButton: View {
    let title: String
    let action: () -> Void

    @Binding var progress: Double

    private var cappedProgress: CGFloat { CGFloat(min(max(progress, 0), 1)) }
    private var isEnabled: Bool { progress >= 1.0 }

    var body: some View {
        Button {
            guard isEnabled else { return }
            action()
        } label: {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.nmGrayscale4)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(.nmGrayscale1)
                        .frame(width: geo.size.width * cappedProgress)

                    Text(title)
                        .foregroundStyle(.nmBackground1Main)
                        .font(.custom(FontName.pretendardSemiBold.rawValue, size: 16))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentTransition(.opacity)
                }
                .animation(.easeInOut(duration: 0.25), value: cappedProgress)
            }
            .frame(height: 56)
        }
        .buttonStyle(.plain)
        //.disabled(!isEnabled)
    }
}

#Preview {
    NMGaugeButton(title: "어쩔", action: {}, progress: .constant(1.0))
}
