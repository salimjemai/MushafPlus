import SwiftUI

/// "Mushaf+ Watch": the Apple Watch companion. Prayer times, the Qibla, a
/// tasbih counter and the verse of the day, fed by the iPhone app through
/// WatchConnectivity (see `WatchStore`). Target set-up is described in
/// docs/STORE_RELEASE.md.
@main
struct MushafWatchApp: App {
    @StateObject private var store = WatchStore.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
