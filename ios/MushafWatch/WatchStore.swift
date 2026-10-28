import Foundation
import WatchConnectivity
import WidgetKit

/// Holds the latest payload from the phone. It arrives as the WatchConnectivity
/// application context (delivered even when this app was not running), is kept
/// in the App Group so the complication can read it, and the complication
/// timelines are reloaded on every update.
final class WatchStore: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchStore()

    @Published private(set) var payload: WatchPayload? = WatchPayload.load()
    @Published private(set) var reachable = false

    /// Recitation check driven from ReciteView; results arrive as messages.
    let recite = ReciteSession()

    private override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    /// Asks the phone for the newest payload when it is reachable (first
    /// launch, or data older than the week it covers).
    func refreshFromPhone() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        guard session.activationState == .activated, session.isReachable else { return }
        session.sendMessage(["request": "payload"], replyHandler: { [weak self] reply in
            guard let json = reply[WatchPayload.key] as? String, !json.isEmpty else { return }
            self?.apply(json: json)
        }, errorHandler: { _ in })
    }

    private func apply(json: String) {
        guard let decoded = WatchPayload.decode(json) else { return }
        WatchPayload.store(json: json)
        DispatchQueue.main.async {
            self.payload = decoded
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        guard activationState == .activated else { return }
        if let json = session.receivedApplicationContext[WatchPayload.key] as? String {
            apply(json: json)
        }
        DispatchQueue.main.async { self.reachable = session.isReachable }
        if payload == nil || payload?.isStale == true {
            refreshFromPhone()
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        if let json = applicationContext[WatchPayload.key] as? String {
            apply(json: json)
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if message["recite.result"] != nil {
            DispatchQueue.main.async { self.recite.apply(result: message) }
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.reachable = session.isReachable
            if !session.isReachable, self.recite.isActive { self.recite.stop() }
        }
        if payload == nil || payload?.isStale == true {
            refreshFromPhone()
        }
    }
}
