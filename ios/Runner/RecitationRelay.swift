import AVFoundation
import Flutter
import Foundation
import Speech
import UIKit
import WatchConnectivity

/// Recitation checking for the Apple Watch. watchOS has no speech
/// recognition of its own, so the watch records its microphone and streams
/// 16 kHz mono PCM to the phone over WatchConnectivity; this class runs
/// Apple's Arabic recogniser on those buffers, aligns the transcript against
/// the surah with `RecitationMatcher` and sends the word statuses back. The
/// watch shows them and buzzes on a wrong word.
///
/// Messages from the watch (`WCSession.sendMessage` / `sendMessageData`):
/// - `recite.start` {surah, from?, to?}: reply {words: [...], ayahOf: [...],
///   keys: [...], ok: Bool, error?: String}
/// - raw audio data (`sendMessageData`), first 4 bytes "RCT1" then Int16 LE
///   samples at 16 kHz
/// - `recite.stop`
/// Messages to the watch: `recite.result` {status: "pmwx…", next: Int,
/// heard: {index: word}, complete: Bool}.
final class RecitationRelay: NSObject {
    static let sampleRate: Double = 16000
    static let magic = Data("RCT1".utf8)

    private var recognizer: SFSpeechRecognizer?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var matcher: RecitationMatcher?
    private var committed = ""
    private var sessionStarted = Date()
    private let format = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: RecitationRelay.sampleRate, channels: 1, interleaved: true)!
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var lastStatus = ""

    private lazy var quran = QuranText()

    var isActive: Bool { matcher != nil }

    // MARK: - Session

    func start(message: [String: Any], session: WCSession, reply: @escaping ([String: Any]) -> Void) {
        stop()
        guard let surah = message["surah"] as? Int, let ayahs = quran.ayahs(ofSurah: surah) else {
            reply(["ok": false, "error": "no-text"])
            return
        }
        let from = max(1, message["from"] as? Int ?? 1)
        let to = min(ayahs.count, message["to"] as? Int ?? ayahs.count)
        guard from <= to else {
            reply(["ok": false, "error": "bad-range"])
            return
        }
        let range = Array(ayahs[(from - 1)..<to])
        var words: [String] = []
        var ayahOf: [Int] = []
        for (i, a) in range.enumerated() {
            for w in a.text.split(separator: " ").map(String.init) where !ArabicNormalizer.tokenize(w).isEmpty {
                words.append(w)
                ayahOf.append(i)
            }
        }
        matcher = RecitationMatcher(words: words, strict: true)
        committed = ""
        lastStatus = ""

        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                guard let self = self else { return }
                guard status == .authorized else {
                    self.matcher = nil
                    reply(["ok": false, "error": "speech-denied"])
                    return
                }
                self.recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ar-SA")) ?? SFSpeechRecognizer(locale: Locale(identifier: "ar"))
                guard let r = self.recognizer, r.isAvailable else {
                    self.matcher = nil
                    reply(["ok": false, "error": "speech-unavailable"])
                    return
                }
                self.beginBackgroundTask()
                self.startRecognitionTask(session: session)
                reply([
                    "ok": true,
                    "words": words,
                    "ayahOf": ayahOf,
                    "keys": range.map { "\(surah):\($0.numberInSurah)" },
                ])
            }
        }
    }

    func stop() {
        request?.endAudio()
        task?.cancel()
        task = nil
        request = nil
        matcher = nil
        endBackgroundTask()
    }

    // MARK: - Audio

    func append(data: Data, session: WCSession) {
        guard matcher != nil, data.count > RecitationRelay.magic.count, data.prefix(RecitationRelay.magic.count) == RecitationRelay.magic else { return }
        // Apple's recogniser stops after about a minute of audio: roll over
        // to a fresh task and keep the text so far.
        if Date().timeIntervalSince(sessionStarted) > 50 {
            startRecognitionTask(session: session)
        }
        let samples = data.dropFirst(RecitationRelay.magic.count)
        let frames = AVAudioFrameCount(samples.count / 2)
        guard frames > 0, let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames) else { return }
        buffer.frameLength = frames
        samples.withUnsafeBytes { raw in
            if let base = raw.baseAddress, let dst = buffer.int16ChannelData?[0] {
                memcpy(dst, base, Int(frames) * 2)
            }
        }
        request?.append(buffer)
    }

    private func startRecognitionTask(session: WCSession) {
        if let old = request {
            old.endAudio()
            task?.finish()
        }
        guard let recognizer = recognizer else { return }
        let req = SFSpeechAudioBufferRecognitionRequest()
        req.shouldReportPartialResults = true
        req.taskHint = .dictation
        if #available(iOS 16.0, *) { req.addsPunctuation = false }
        request = req
        sessionStarted = Date()
        let base = committed
        task = recognizer.recognitionTask(with: req) { [weak self] result, error in
            guard let self = self, self.matcher != nil else { return }
            if let result = result {
                let text = result.bestTranscription.formattedString
                let full = (base + " " + text).trimmingCharacters(in: .whitespaces)
                if result.isFinal { self.committed = full }
                self.publish(full, isFinal: result.isFinal, session: session)
            }
            if error != nil, self.request === req {
                // Transient failure (silence, network): continue with a new task.
                self.committed = base
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                    guard let self = self, self.matcher != nil else { return }
                    self.startRecognitionTask(session: session)
                }
            }
        }
    }

    private func publish(_ text: String, isFinal: Bool, session: WCSession) {
        guard let matcher = matcher else { return }
        let r = matcher.match(text)
        let status = r.statusString
        if status == lastStatus && !isFinal { return }
        lastStatus = status
        var heard: [String: String] = [:]
        for (i, w) in r.heard { heard[String(i)] = w }
        let msg: [String: Any] = ["recite.result": true, "status": status, "next": r.nextIndex, "heard": heard, "complete": r.complete, "final": isFinal]
        guard session.isReachable else { return }
        session.sendMessage(msg, replyHandler: nil, errorHandler: nil)
    }

    // MARK: - Background time (the watch wakes this app in the background)

    private func beginBackgroundTask() {
        endBackgroundTask()
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "MushafWatchRecite") { [weak self] in
            self?.endBackgroundTask()
        }
    }

    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
}

/// The Uthmani text, read from the Flutter asset bundle (the same
/// `assets/data/quran_uthmani.json` the app ships), loaded once on first use.
final class QuranText {
    struct Ayah {
        let number: Int
        let surah: Int
        let numberInSurah: Int
        let text: String
    }

    private var bySurah: [Int: [Ayah]] = [:]
    private var loaded = false

    func ayahs(ofSurah surah: Int) -> [Ayah]? {
        load()
        return bySurah[surah]
    }

    private func load() {
        guard !loaded else { return }
        loaded = true
        let key = FlutterDartProject.lookupKey(forAsset: "assets/data/quran_uthmani.json")
        guard let path = Bundle.main.path(forResource: key, ofType: nil),
              let data = FileManager.default.contents(atPath: path),
              let list = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { return }
        for item in list {
            guard let n = item["n"] as? Int, let s = item["s"] as? Int, let a = item["a"] as? Int, let t = item["t"] as? String else { continue }
            bySurah[s, default: []].append(Ayah(number: n, surah: s, numberInSurah: a, text: t))
        }
    }
}
