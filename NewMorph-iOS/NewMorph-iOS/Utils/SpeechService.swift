import AVFoundation
import Foundation
import Speech

final class SpeechService {
    private var audioEngine: AVAudioEngine?
    private var analyzerFormat: AVAudioFormat?
    
    private(set) var enTranscriber: DictationTranscriber?
    private(set) var koTranscriber: DictationTranscriber?
    private var speechDetector: SpeechDetector?
    private var speechAnalyzer: SpeechAnalyzer?
    
    private var speechStream: AsyncStream<AnalyzerInput>?
    private var speechStreamContinuation: AsyncStream<AnalyzerInput>.Continuation?
    private(set) var detectorStream: AsyncStream<Float>?
    private var detectorStreamContinuation: AsyncStream<Float>.Continuation?
    
    private let converter = BufferConverter()
    private var isPreparing = false
    
    private var routeObserver: NSObjectProtocol?
    private var routeChangeWorkItem: DispatchWorkItem?
    
    func startTranscribing() async throws {
        guard !isPreparing else { return }
        isPreparing = true
        defer { isPreparing = false }
        
        try await prepareSpeechModules()
        try startAudio()
    }
    
    func stopTranscribing() async {
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        speechStreamContinuation?.finish()
        detectorStreamContinuation?.finish()
        
        try? await speechAnalyzer?.finalizeAndFinishThroughEndOfInput()
        speechAnalyzer = nil
        enTranscriber = nil
        koTranscriber = nil
        speechDetector = nil
        
        let session = AVAudioSession.sharedInstance()
        try? session.setPreferredInput(nil)
        try? session.setActive(false, options: .notifyOthersOnDeactivation)
        
        removeRouteObserver()
    }
}

// MARK: - Set up Modules

private extension SpeechService {
    func prepareSpeechModules() async throws {
        let en = makeTranscriber(locale: "en-US")
        let ko = makeTranscriber(locale: "ko-KR")
        let detector = SpeechDetector(
            detectionOptions: .init(sensitivityLevel: .high),
            reportResults: true
        )
        
        try await ensureModel(transcriber: en, locale: Locale(identifier: "en-US"))
        try await ensureModel(transcriber: ko, locale: Locale(identifier: "ko-KR"))
        
        self.enTranscriber = en
        self.koTranscriber = ko
        self.speechDetector = detector
        let modules: [any SpeechModule] = [en, ko, detector]
        let analyzer = SpeechAnalyzer(modules: modules)
        self.speechAnalyzer = analyzer
        
        self.analyzerFormat = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: modules)
        
        // Setup Stream
        (speechStream, speechStreamContinuation) = AsyncStream<AnalyzerInput>.makeStream()
        (detectorStream, detectorStreamContinuation) = AsyncStream<Float>.makeStream(
            bufferingPolicy: .bufferingNewest(1)
        )
        
        guard let speechStream else { return }
        try await analyzer.start(inputSequence: speechStream)
    }
    
    func makeTranscriber(locale: String) -> DictationTranscriber {
        DictationTranscriber(
            locale: Locale(identifier: locale),
            contentHints: [],
            transcriptionOptions: [],
            reportingOptions: [.volatileResults],
            attributeOptions: [.audioTimeRange]
        )
    }
        
    func startAudio() throws {
        let engine = AVAudioEngine()
        let session = AVAudioSession.sharedInstance()
        
        try configureSessionAndActivate(session)
        
        let inputNode = engine.inputNode
        let micFormat = inputNode.outputFormat(forBus: 0)
        if analyzerFormat == nil { analyzerFormat = micFormat }
        
        inputNode.installTap(onBus: 0, bufferSize: 2048, format: micFormat) { [weak self] buffer, _ in
            guard let self else { return }
            
            let level = Self.calculateMicLevel(from: buffer)
            self.detectorStreamContinuation?.yield(level)
            
            Task {
                guard let cont = self.speechStreamContinuation,
                      let fmt = self.analyzerFormat else { return }
                
                let converted = (buffer.format == fmt)
                ? buffer
                : (try? self.converter.convertBuffer(buffer, to: fmt)) ?? buffer
                
                cont.yield(AnalyzerInput(buffer: converted))
            }
        }
        
        observeRouteChanges()
        
        engine.prepare()
        try engine.start()
        self.audioEngine = engine
    }
    
    private func restartEnginePreservingStreams() throws {
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        
        if let modules = speechAnalyzer?.modules {
            Task { [weak self] in
                guard let self else { return }
                let fmt = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: modules)
                self.analyzerFormat = fmt
            }
        }
        
        try startAudio()
    }
}

// MARK: - Session helpers
private extension SpeechService {
    func configureSessionAndActivate(_ session: AVAudioSession) throws {
        let hasBT = hasBluetoothInput(session)
        
        // HFP 마이크 품질/지연 안정화를 위해 BT 시 voiceChat 권장
        let mode: AVAudioSession.Mode = hasBT ? .voiceChat : .measurement
        try session.setCategory(
            .playAndRecord,
            mode: mode,
            options: [.duckOthers, .allowBluetoothHFP, .allowBluetoothA2DP]
        )
        
        if hasBT { try routeToBluetoothIfAvailable(session: session) }
        
        try session.setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    func hasBluetoothInput(_ session: AVAudioSession) -> Bool {
        (session.availableInputs ?? []).contains {
            $0.portType == .bluetoothHFP || $0.portType == .bluetoothLE
        }
    }
    
    func routeToBluetoothIfAvailable(session: AVAudioSession) throws {
        guard let inputs = session.availableInputs else { return }
        let bt = inputs.first { $0.portType == .bluetoothHFP }
        ?? inputs.first { $0.portType == .bluetoothLE }
        
        if let bt {
            try session.setPreferredInput(bt)
            // 필요 시: try? session.setPreferredSampleRate(16_000)
        } else {
            try? session.setPreferredInput(nil)
        }
    }
}

// MARK: - Observing
private extension SpeechService {
    func observeRouteChanges() {
        removeRouteObserver()
        routeObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: AVAudioSession.sharedInstance(),
            queue: .main
        ) { [weak self] note in
            self?.handleRouteChange(note)
        }
    }
    
    func removeRouteObserver() {
        if let token = routeObserver {
            NotificationCenter.default.removeObserver(token)
            routeObserver = nil
        }
    }
    
    func handleRouteChange(_ note: Notification) {
        let session = AVAudioSession.sharedInstance()
        
        guard let raw = note.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: raw),
              [.newDeviceAvailable, .oldDeviceUnavailable, .categoryChange, .override].contains(reason)
        else { return }
        
        routeChangeWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }
            do {
                try self.routeToBluetoothIfAvailable(session: session)
                try self.restartEnginePreservingStreams()
            } catch {
                print("Route change handling error: \(error)")
            }
        }
        routeChangeWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: work)
    }
}

// MARK: - Model install / management / Utils
extension SpeechService {
    func ensureModel(transcriber: DictationTranscriber, locale: Locale) async throws {
        let supported = await DictationTranscriber.supportedLocales.map { $0.identifier(.bcp47) }
        guard supported.contains(locale.identifier(.bcp47)) else { return }

        let installed = await Set(DictationTranscriber.installedLocales).map { $0.identifier(.bcp47) }
        if installed.contains(locale.identifier(.bcp47)) { return }

        if let downloader = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
            try await downloader.downloadAndInstall()
        }
    }

    func deallocate() async {
        let allocated = await AssetInventory.allocatedLocales
        for locale in allocated { await AssetInventory.deallocate(locale: locale) }
    }

    nonisolated private static func calculateMicLevel(from buffer: AVAudioPCMBuffer) -> Float {
        guard let data = buffer.floatChannelData?[0] else { return -70 }
        let n = Int(buffer.frameLength)
        var sum: Float = 0
        for i in 0..<n { sum += data[i] * data[i] }
        let rms = sqrt(max(sum / Float(max(n, 1)), .leastNonzeroMagnitude))
        let db = 20 * log10(rms)
        return db.isFinite ? db : -70
    }
}

// MARK: - Buffer Converter
final class BufferConverter {
    enum Error: Swift.Error { case failedToCreateConverter, failedToCreateConversionBuffer, conversionFailed(NSError?) }
    private var converter: AVAudioConverter?
    func convertBuffer(_ buffer: AVAudioPCMBuffer, to format: AVAudioFormat) throws -> AVAudioPCMBuffer {
        let inputFormat = buffer.format
        guard inputFormat != format else { return buffer }
        if converter == nil || converter?.outputFormat != format {
            converter = AVAudioConverter(from: inputFormat, to: format)
            converter?.primeMethod = .none
        }
        guard let converter else { throw Error.failedToCreateConverter }
        let ratio = converter.outputFormat.sampleRate / converter.inputFormat.sampleRate
        let scaled = Double(buffer.frameLength) * ratio
        let cap = AVAudioFrameCount(scaled.rounded(.up))
        guard let out = AVAudioPCMBuffer(pcmFormat: converter.outputFormat, frameCapacity: cap)
        else { throw Error.failedToCreateConversionBuffer }
        var nsError: NSError?
        let status = converter.convert(to: out, error: &nsError) { _, inStatus in
            inStatus.pointee = .haveData
            return buffer
        }
        guard status != .error else { throw Error.conversionFailed(nsError) }
        return out
    }
}

extension SpeechDetector: @retroactive SpeechModule, @unchecked @retroactive Sendable {}
