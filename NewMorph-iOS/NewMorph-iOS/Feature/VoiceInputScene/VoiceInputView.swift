import SwiftUI

struct VoiceInputView: View {
    var onCompleted: (String) -> Void

    @State private var viewModel = VoiceInputViewModel()

    @State private var levels: [CGFloat] = []
    @State private var progress: Double = 0

    @State private var startTask: Task<Void, Never>?
    private let startDelay: Duration = .milliseconds(600)

    var body: some View {
        VStack {
            Text("Today’s Blahblah")
                .font(.custom(FontName.pretendardBold.rawValue, size: 24))
                .padding(.top, 24)
                .padding(.bottom, 50)

            DBWaveformView(levels: levels)
                .onChange(of: viewModel.micLevelDB) { _, newDB in
                    appendDBSample(newDB)
                }
                .padding(.bottom, 20)

            NMGaugeButton(
                title: "next",
                action: {
                    viewModel.stop()
                    completeAndDismissIfPossible()
                },
                progress: $progress
            )
            .frame(height: 97)
        }
        .ignoresSafeArea()
        .onAppear {
            if levels.isEmpty { levels = Array(repeating: -60, count: 24) }

            startTask?.cancel()
            startTask = Task {
                try? await Task.sleep(for: startDelay)
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    viewModel.start()
                }
            }
        }
        .onDisappear {
            startTask?.cancel()
            startTask = nil
            if viewModel.isRecording { viewModel.stop() }
        }
    }
}

private extension VoiceInputView {
    func appendDBSample(_ db: Float) {
        var clamped = CGFloat(db)
        if !clamped.isFinite { clamped = -70 }
        clamped = max(min(clamped, 0), -80)
        levels.append(clamped)
        if levels.count > 200 { levels.removeFirst(levels.count - 200) }
    }

    func completeAndDismissIfPossible() {
        let text = viewModel.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        onCompleted(text)
    }
}
