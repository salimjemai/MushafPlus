import AVFoundation
import Foundation
import WatchConnectivity
import WatchKit

/// Drives a recitation check from the watch: records the microphone with
/// AVAudioEngine, converts to 16 kHz mono Int16 and streams half-second
/// chunks to the iPhone (`RecitationRelay` there recognises and matches),
/// then publishes the word statuses it gets back and plays a haptic for
/// every newly wrong word. The iPhone app is woken in the background by the
/// first message, but recognition is most reliable while it is open.
final class ReciteSession: NSObject, ObservableObject {
    enum State: Equatable { case idle, starting, listening, failed(String) }

    @Published private(set) var state: State = .idle
    @Published private(set) var words: [String] = []
    @Published private(set) var ayahOf: [Int] = []
    @Published private(set) var keys: [String] = []
    @Published private(set) var statuses: [Character] = []
    @Published private(set) var next = 0
    @Published private(set) var wrongCount = 0
    @Published private(set) var complete = false

    private let engine = AVAudioEngine()
    private var converter: AVAudioConverter?
    private let targetFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 16000, channels: 1, interleaved: true)!
    private var pending = Data()
    private var flagged = Set<Int>()

    static let magic = Data("RCT1".utf8)

    var isActive: Bool { state == .starting || state == .listening }

    func toggle(surah: Int) {
        if isActive { stop() } else { start(surah: surah) }
    }

    func start(surah: Int) {
        guard WCSession.isSupported() else {
            state = .failed("no-session")
            return
        }
        let session = WCSession.default
        guard session.activationState == .activated, session.isReachable else {
            state = .failed("phone-unreachable")
            return
        }
        state = .starting
        statuses = []
        next = 0
        wrongCount = 0
        complete = false
        flagged = []
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                guard let self = self else { return }
                guard granted else {
                    self.state = .failed("mic-denied")
                    return
                }
                session.sendMessage(["recite.start": true, "surah": surah], replyHandler: { reply in
                    DispatchQueue.main.async {
                        guard reply["ok"] as? Bool == true else {
                            self.state = .failed(reply["error"] as? String ?? "phone-error")
                            return
                        }
                        self.words = reply["words"] as? [String] ?? []
                        self.ayahOf = reply["ayahOf"] as? [Int] ?? []
                        self.keys = reply["keys"] as? [String] ?? []
                        self.statuses = Array(repeating: "p", count: self.words.count)
                        self.beginRecording()
                    }
                }, errorHandler: { error in
                    DispatchQueue.main.async { self.state = .failed(error.localizedDescription) }
                })
            }
        }
    }

    func stop() {
        if engine.isRunning {
            engine.inputNode.removeTap(onBus: 0)
            engine.stop()
        }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        if WCSession.isSupported(), WCSession.default.isReachable, isActive {
            WCSession.default.sendMessage(["recite.stop": true], replyHandler: nil, errorHandler: nil)
        }
        state = .idle
    }

    /// Called by `WatchStore` for every `recite.result` message.
    func apply(result: [String: Any]) {
        guard isActive, let status = result["status"] as? String else { return }
        let chars = Array(status)
        guard chars.count == words.count else { return }
        statuses = chars
        next = result["next"] as? Int ?? 0
        complete = result["complete"] as? Bool ?? false
        wrongCount = chars.filter { $0 == "w" }.count
        let isFinal = result["final"] as? Bool ?? false
        // Buzz once per word confirmed wrong (the reciter has moved past it).
        for (i, c) in chars.enumerated() where c == "w" && !flagged.contains(i) {
            if isFinal || i < next - 1 {
                flagged.insert(i)
                WKInterfaceDevice.current().play(.failure)
            }
        }
        if complete {
            WKInterfaceDevice.current().play(.success)
        }
    }

    // MARK: - Recording

    private func beginRecording() {
        let audio = AVAudioSession.sharedInstance()
        do {
            try audio.setCategory(.record, mode: .measurement, options: [])
            try audio.setActive(true)
        } catch {
            state = .failed("audio-session")
            return
        }
        let input = engine.inputNode
        let inputFormat = input.outputFormat(forBus: 0)
        guard inputFormat.sampleRate > 0, let converter = AVAudioConverter(from: inputFormat, to: targetFormat) else {
            state = .failed("audio-format")
            return
        }
        self.converter = converter
        pending = Data()
        input.installTap(onBus: 0, bufferSize: 4096, format: inputFormat) { [weak self] buffer, _ in
            self?.handle(buffer: buffer)
        }
        do {
            engine.prepare()
            try engine.start()
            state = .listening
        } catch {
            state = .failed("audio-engine")
        }
    }

    private func handle(buffer: AVAudioPCMBuffer) {
        guard let converter = converter else { return }
        let ratio = targetFormat.sampleRate / buffer.format.sampleRate
        let capacity = AVAudioFrameCount(Double(buffer.frameLength) * ratio) + 16
        guard let out = AVAudioPCMBuffer(pcmFormat: targetFormat, frameCapacity: capacity) else { return }
        var consumed = false
        var error: NSError?
        converter.convert(to: out, error: &error) { _, status in
            if consumed {
                status.pointee = .noDataNow
                return nil
            }
            consumed = true
            status.pointee = .haveData
            return buffer
        }
        guard error == nil, out.frameLength > 0, let channel = out.int16ChannelData?[0] else { return }
        let chunk = Data(bytes: channel, count: Int(out.frameLength) * 2)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.pending.append(chunk)
            // Half a second of 16 kHz Int16 audio per message.
            if self.pending.count >= 16000 {
                self.flush()
            }
        }
    }

    private func flush() {
        guard !pending.isEmpty, WCSession.isSupported(), WCSession.default.isReachable else {
            pending = Data()
            return
        }
        var data = ReciteSession.magic
        data.append(pending)
        pending = Data()
        WCSession.default.sendMessageData(data, replyHandler: nil, errorHandler: nil)
    }
}
