import SwiftUI

struct VoiceInputView: View {
    var onCompleted: (String) -> Void?

    @State private var viewModel = VoiceInputViewModel()

    @State private var levels: [CGFloat] = []
    private let visibleBars = 28

    var body: some View {
        VStack(spacing: 16) {
            // Title
            Text("Today’s Blahblah")
                .font(.system(size: 22, weight: .heavy))
                .padding(.top, 4)

            // Waveform (dB 기반)
            DBWaveformView(levels: levels, visibleBars: visibleBars)
                .frame(maxWidth: .infinity)
                .onChange(of: viewModel.micLevelDB) { _, newDB in
                    appendDBSample(newDB)
                }

            // 상태표시
            HStack {
                Circle().frame(width: 8, height: 8)
                    .foregroundStyle(viewModel.isRecording ? .green : .secondary)
                Text(viewModel.isRecording ? "Recording…" : "Idle")
                    .font(.footnote).foregroundStyle(.secondary)
                Spacer()
                Text(String(format: "%.1f dB", viewModel.micLevelDB))
                    .font(.footnote).monospaced().foregroundStyle(.secondary)
            }

            Button {
                if viewModel.isRecording {
                    viewModel.stop()
                    completeAndDismissIfPossible()
                } else {
                    viewModel.start()
                }
            } label: {
                Text(viewModel.isRecording ? "정지" : "녹음")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
            }
            .buttonStyle(.borderedProminent)
            .tint(.black)
            .padding(.top, 8)
        }
        .onAppear {
            if levels.isEmpty { levels = Array(repeating: -60, count: visibleBars) }
            viewModel.start()
        }
        .onDisappear {
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
        print("🥹", text)
        onCompleted(text)
    }
}
