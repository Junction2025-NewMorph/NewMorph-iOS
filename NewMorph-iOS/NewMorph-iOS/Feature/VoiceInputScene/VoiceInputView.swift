import SwiftUI

struct VoiceInputView: View {
    @State private var viewModel = VoiceInputViewModel()

    @State private var levels: [CGFloat] = []
    private let visibleBars = 28

    var body: some View {
        VStack(spacing: 16) {
            // Title
            Text("Today’s Blahblah")
                .font(.system(size: 22, weight: .heavy))
                .padding(.top, 4)

            // Waveform
            DBWaveformView(levels: levels, visibleBars: visibleBars)
                .frame(maxWidth: .infinity)
                .onChange(of: viewModel.micLevelDB) { _, newDB in
                    // mic dB를 주기적으로 쌓기 (여기선 값 변화마다)
                    appendDBSample(newDB)
                }

            // (옵션) 상태 라벨
            HStack {
                Circle().frame(width: 8, height: 8)
                    .foregroundStyle(viewModel.isRecording ? .green : .secondary)
                Text(viewModel.isRecording ? "Recording…" : "Idle")
                    .font(.footnote).foregroundStyle(.secondary)
                Spacer()
                Text(String(format: "%.1f dB", viewModel.micLevelDB))
                    .font(.footnote).monospaced().foregroundStyle(.secondary)
            }

            // Buttons
            HStack(spacing: 12) {
                Button {
                    viewModel.isRecording ? viewModel.stop() : viewModel.start()
                } label: {
                    Text(viewModel.isRecording ? "정지" : "녹음")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .buttonStyle(.borderedProminent)
                .tint(.black)

                Button {
                    // TODO: 다음 단계 이동
                } label: {
                    Text("다음")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .buttonStyle(.bordered)
                .disabled(true) // 예시로 비활성
            }
            .padding(.top, 8)
        }
        .onAppear {
            // 시작 시 첫 샘플(무음일 때 -70dB 근처로 초기화)
            if levels.isEmpty { levels = Array(repeating: -60, count: visibleBars) }
        }
        .onDisappear {
            if viewModel.isRecording { viewModel.stop() }
        }
    }

    private func appendDBSample(_ db: Float) {
        // -80 ~ 0 dB 범위 가정
        var clamped = CGFloat(db)
        if !clamped.isFinite { clamped = -70 }
        clamped = max(min(clamped, 0), -80)

        levels.append(clamped)
        if levels.count > 200 { levels.removeFirst(levels.count - 200) } // 메모리 보호
    }
}
