import SwiftUI
import NaturalLanguage

struct VoiceInputView: View {
    var onCompleted: (String) -> Void

    @State private var viewModel = VoiceInputViewModel()

    @State private var levels: [CGFloat] = []
    @State private var progress: Double = 0
    @State private var startTask: Task<Void, Never>?
    
    private let startDelay: Duration = .milliseconds(600)
    private let targetWordCount = 20

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
                title: "Next",
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

            progress = 0

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
        .onChange(of: viewModel.transcript) { _, newText in
            updateProgress(with: newText)
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

    func wordCount(_ text: String) -> Int {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        var count = 0
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            let token = text[range]
            if token.rangeOfCharacter(from: .letters.union(.decimalDigits)) != nil {
                count += 1
            }
            return true
        }
        return count
    }

    func updateProgress(with text: String) {
        let wc = wordCount(text)
        let pct = min(Double(wc) / 20.0, 1.0)
        withAnimation(.easeInOut(duration: 0.2)) {
            progress = pct
        }
    }
}
