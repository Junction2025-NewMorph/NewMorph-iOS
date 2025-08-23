import SwiftUI

struct VoiceInputView: View {
    @State private var viewModel = VoiceInputViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle().frame(width: 8, height: 8)
                    .foregroundStyle(viewModel.isRecording ? .green : .secondary)
                Text(viewModel.isRecording ? "Recording…" : "Idle")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text(String(format: "%.1f dB", viewModel.micLevelDB))
                    .font(.caption).monospaced()
                    .foregroundStyle(.secondary)
            }
            
            ScrollView {
                Text(viewModel.transcript.isEmpty ? "—" : viewModel.transcript)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                    .textSelection(.enabled)
            }
            
            if let err = viewModel.lastError {
                Text(err).foregroundStyle(.red).font(.footnote)
            }
            
            HStack(spacing: 12) {
                Button(viewModel.isRecording ? "Stop" : "Start") {
                    viewModel.isRecording ? viewModel.stop() : viewModel.start()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Clear") { viewModel.clear() }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.isRecording)
            }        }
        .padding()
        .onDisappear { if viewModel.isRecording { viewModel.stop() } }
    }
}
