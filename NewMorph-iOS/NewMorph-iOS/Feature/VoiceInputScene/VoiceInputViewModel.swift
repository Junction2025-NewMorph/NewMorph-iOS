import SwiftUI
import Speech
import AVFoundation

@MainActor
@Observable
final class VoiceInputViewModel {
    private let service = SpeechService()

    var isRecording = false
    var micLevelDB: Float = 0
    var transcript: String = ""
    var lastError: String?

    private var koTask: Task<Void, Never>?
    private var levelTask: Task<Void, Never>?

    private var koFinalText: String = ""
    private var koVolatileText: String = ""

    func start() {
        guard !isRecording else { return }
        isRecording = true
        lastError = nil
        transcript = ""
        koFinalText = ""
        koVolatileText = ""

        Task {
            do {
                try await service.startTranscribing()

                // TODO: - 일단 한국어 Transcriber만 추가. 나중에 영어가 필요하면 그때 다시오는 것으로. 수정여지 있음.
                if let ko = service.koTranscriber {
                    koTask?.cancel()
                    koTask = Task { [weak self] in
                        guard let self else { return }
                        do {
                            for try await r in ko.results {
                                let raw = String(r.text.characters)
                                let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
                                guard !text.isEmpty else { continue }

                                if r.isFinal {
                                    await MainActor.run {
                                        self.koFinalText += (self.koFinalText.isEmpty ? "" : " ") + text
                                        self.koVolatileText = ""
                                        self.transcript = self.koFinalText
                                    }
                                } else {
                                    await MainActor.run {
                                        self.koVolatileText = text
                                        self.transcript = self.koFinalText
                                            + (self.koVolatileText.isEmpty ? "" : (self.koFinalText.isEmpty ? "" : " ") + self.koVolatileText)
                                    }
                                }
                            }
                        } catch {
                            await MainActor.run { self.lastError = error.localizedDescription }
                        }
                    }
                }

                if let levels = service.detectorStream {
                    levelTask?.cancel()
                    levelTask = Task { [weak self] in
                        guard let self else { return }
                        for await v in levels { await MainActor.run { self.micLevelDB = v } }
                    }
                }
            } catch {
                await MainActor.run {
                    self.lastError = error.localizedDescription
                    self.isRecording = false
                }
            }
        }
    }

    func stop() {
        guard isRecording else { return }
        isRecording = false
        koTask?.cancel(); koTask = nil
        levelTask?.cancel(); levelTask = nil
        Task { await service.stopTranscribing() }
    }

    func clear() {
        transcript = ""
        lastError = nil
        koFinalText = ""
        koVolatileText = ""
    }
}
