import Flutter
import Foundation
import WatchConnectivity

/// The phone side of the Apple Watch companion.
///
/// Receives the watch payload from Dart (channel `mushafplus/watch`, method
/// `publish`, one JSON string: place, a week of prayer times and verses, UI
/// labels), keeps a copy in the App Group and hands it to the paired Apple
/// Watch through WatchConnectivity as the application context. The watch
/// app stores it in its own App Group container, which its complication
/// reads. Recitation audio from the watch is handed to `RecitationRelay`.
final class WatchBridge: NSObject, WCSessionDelegate {
  static let appGroup = "group.com.salimjemai.mushafplus"
  static let payloadKey = "watchPayload"
  static let channelName = "mushafplus/watch"

  private var pendingJSON: String?
  private let recitation = RecitationRelay()

  private var defaults: UserDefaults? { UserDefaults(suiteName: WatchBridge.appGroup) }

  func activate() {
    guard WCSession.isSupported() else { return }
    let session = WCSession.default
    session.delegate = self
    session.activate()
  }

  func attach(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: WatchBridge.channelName, binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(FlutterMethodNotImplemented)
        return
      }
      switch call.method {
      case "publish":
        guard let json = call.arguments as? String else {
          result(FlutterError(code: "bad-args", message: "publish expects a JSON string", details: nil))
          return
        }
        self.publish(json)
        result(nil)
      case "isPaired":
        result(WCSession.isSupported() && WCSession.default.isPaired)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func publish(_ json: String) {
    defaults?.set(json, forKey: WatchBridge.payloadKey)
    guard WCSession.isSupported() else { return }
    let session = WCSession.default
    guard session.activationState == .activated else {
      pendingJSON = json
      return
    }
    send(json, over: session)
  }

  private func send(_ json: String, over session: WCSession) {
    guard session.isPaired, session.isWatchAppInstalled else { return }
    do {
      // The application context is the latest state: the system keeps only
      // the newest one and delivers it when the watch app next runs.
      try session.updateApplicationContext([WatchBridge.payloadKey: json])
    } catch {
      NSLog("Mushaf+ watch: could not send payload: \(error.localizedDescription)")
    }
  }

  // MARK: - WCSessionDelegate

  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    guard activationState == .activated else { return }
    if let json = pendingJSON ?? defaults?.string(forKey: WatchBridge.payloadKey) {
      pendingJSON = nil
      send(json, over: session)
    }
  }

  func sessionDidBecomeInactive(_ session: WCSession) {}

  func sessionDidDeactivate(_ session: WCSession) {
    // The user switched to another watch: start again for the new one.
    session.activate()
  }

  func sessionWatchStateDidChange(_ session: WCSession) {
    if let json = defaults?.string(forKey: WatchBridge.payloadKey) {
      send(json, over: session)
    }
  }

  /// Requests from the watch: the latest payload (first launch, or after a
  /// long time without the phone app running) and recitation sessions.
  func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
    if message["request"] as? String == "payload" {
      replyHandler([WatchBridge.payloadKey: defaults?.string(forKey: WatchBridge.payloadKey) ?? ""])
    } else if message["recite.start"] != nil {
      recitation.start(message: message, session: session, reply: replyHandler)
    } else if message["recite.stop"] != nil {
      recitation.stop()
      replyHandler(["ok": true])
    } else {
      replyHandler([:])
    }
  }

  func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
    if message["recite.stop"] != nil { recitation.stop() }
  }

  func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
    recitation.append(data: messageData, session: session)
  }

  func sessionReachabilityDidChange(_ session: WCSession) {
    if !session.isReachable { recitation.stop() }
  }
}
