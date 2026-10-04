import AVFoundation
import Foundation
import Observation
import Speech

/// Listens with the microphone and turns speech into text on the iPhone, with Apple's Speech framework.
///
/// Malaysian English is used when the device supports it, with a vocabulary hint for local words
/// (ringgit, tapau, mamak, Grab). Audio never leaves the phone when on-device recognition is available.
@MainActor
@Observable
final class SpeechCapture {
    enum Phase: Equatable {
        case idle, listening, finishing, done
        case failed(String)
    }

    private(set) var transcript = ""
    private(set) var phase: Phase = .idle
    /// Input loudness from 0 to 1, for the level bars.
    private(set) var level: Double = 0
    /// When the words last changed, to finish by itself after a pause.
    private(set) var lastChange = Date()

    private let engine = AVAudioEngine()
    @ObservationIgnored private var request: SFSpeechAudioBufferRecognitionRequest?
    @ObservationIgnored private var task: SFSpeechRecognitionTask?
    @ObservationIgnored private var finishContinuation: CheckedContinuation<String, Never>?

    private static let vocabulary = [
        "ringgit", "RM", "sen", "Grab", "GrabFood", "tapau", "mamak", "nasi lemak", "teh tarik", "teh ais", "kopi",
        "roti canai", "ZUS", "Shopee", "Lazada", "Touch 'n Go", "Lotus's", "Jaya Grocer", "Speedmart", "petrol", "toll",
        "gaji", "duit", "makan",
    ]

    func start() async {
        guard phase != .listening else { return }
        transcript = ""
        level = 0
        guard await Self.requestAccess() else {
            phase = .failed("Kira needs the microphone and speech recognition to listen. You can allow both in Settings, or type it instead.")
            return
        }
        guard let recognizer = Self.makeRecognizer(), recognizer.isAvailable else {
            phase = .failed("Speech recognition isn't available right now. You can type it instead.")
            return
        }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)

            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            request.addsPunctuation = true
            request.contextualStrings = Self.vocabulary
            if recognizer.supportsOnDeviceRecognition {
                request.requiresOnDeviceRecognition = true
            }
            self.request = request

            let input = engine.inputNode
            let format = input.outputFormat(forBus: 0)
            guard format.sampleRate > 0, format.channelCount > 0 else {
                phase = .failed("There's no microphone to listen with. You can type it instead.")
                return
            }
            Self.installTap(on: input, format: format, request: request) { [weak self] level in
                guard let self else { return }
                Task { @MainActor in self.level = level }
            }
            engine.prepare()
            try engine.start()
            lastChange = Date()
            phase = .listening
            task = recognizer.recognitionTask(with: request, resultHandler: Self.resultHandler(for: self))
        } catch {
            stopAudio()
            phase = .failed("The microphone couldn't start. You can type it instead.")
        }
    }

    /// Stops listening and returns the final words, waiting briefly for the recognizer to finish.
    func finish() async -> String {
        guard phase == .listening else { return transcript }
        phase = .finishing
        stopAudio()
        request?.endAudio()
        let text = await withCheckedContinuation { (continuation: CheckedContinuation<String, Never>) in
            finishContinuation = continuation
            Task { @MainActor [weak self] in
                try? await Task.sleep(for: .seconds(1.5))
                self?.resolveFinish()
            }
        }
        task = nil
        request = nil
        phase = .done
        Self.deactivateSession()
        return text
    }

    func cancel() {
        task?.cancel()
        task = nil
        stopAudio()
        request = nil
        resolveFinish()
        phase = .idle
        Self.deactivateSession()
    }

    // MARK: Results

    private func receive(text: String?, isFinal: Bool, failed: Bool) {
        if let text, text != transcript {
            transcript = text
            lastChange = Date()
        }
        if isFinal || failed {
            resolveFinish()
            if phase == .listening {
                stopAudio()
                phase = .done
            }
        }
    }

    private func resolveFinish() {
        guard let continuation = finishContinuation else { return }
        finishContinuation = nil
        continuation.resume(returning: transcript)
    }

    private func stopAudio() {
        if engine.isRunning { engine.stop() }
        engine.inputNode.removeTap(onBus: 0)
        level = 0
    }

    // MARK: Helpers (not tied to the main actor: the audio and recognition callbacks run on other threads)

    private nonisolated static func installTap(
        on input: AVAudioInputNode,
        format: AVAudioFormat,
        request: SFSpeechAudioBufferRecognitionRequest,
        level: @escaping @Sendable (Double) -> Void
    ) {
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
            level(loudness(of: buffer))
        }
    }

    private nonisolated static func resultHandler(for capture: SpeechCapture) -> (SFSpeechRecognitionResult?, Error?) -> Void {
        { [weak capture] result, error in
            guard let capture else { return }
            let text = result?.bestTranscription.formattedString
            let isFinal = result?.isFinal ?? false
            let failed = error != nil
            Task { @MainActor in
                capture.receive(text: text, isFinal: isFinal, failed: failed)
            }
        }
    }

    private nonisolated static func loudness(of buffer: AVAudioPCMBuffer) -> Double {
        guard let samples = buffer.floatChannelData?[0] else { return 0 }
        let count = Int(buffer.frameLength)
        guard count > 0 else { return 0 }
        var sum: Float = 0
        for index in 0..<count { sum += samples[index] * samples[index] }
        let rms = (sum / Float(count)).squareRoot()
        let decibels = 20 * log10(max(rms, 0.000_01))
        return Double(min(max((decibels + 50) / 40, 0), 1))
    }

    private nonisolated static func requestAccess() async -> Bool {
        let speech = await withCheckedContinuation { (continuation: CheckedContinuation<SFSpeechRecognizerAuthorizationStatus, Never>) in
            SFSpeechRecognizer.requestAuthorization { continuation.resume(returning: $0) }
        }
        guard speech == .authorized else { return false }
        return await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
            AVAudioApplication.requestRecordPermission { continuation.resume(returning: $0) }
        }
    }

    private nonisolated static func makeRecognizer() -> SFSpeechRecognizer? {
        let supported = Set(SFSpeechRecognizer.supportedLocales().map { $0.identifier.replacingOccurrences(of: "_", with: "-") })
        for identifier in ["en-MY", "en-SG", "en-GB", "en-US"] where supported.contains(identifier) {
            if let recognizer = SFSpeechRecognizer(locale: Locale(identifier: identifier)) { return recognizer }
        }
        return SFSpeechRecognizer()
    }

    private nonisolated static func deactivateSession() {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
