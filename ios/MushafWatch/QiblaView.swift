import CoreLocation
import SwiftUI

/// Live Qibla compass. The position comes from the phone's prayer place; the
/// watch's own GPS is used when none was sent (Series 5 and later have a
/// compass; older watches show the bearing alone).
struct QiblaView: View {
    @EnvironmentObject private var store: WatchStore
    @StateObject private var compass = CompassModel()

    var body: some View {
        let payload = store.payload
        let lat = compass.location?.coordinate.latitude ?? payload?.latitude
        let lng = compass.location?.coordinate.longitude ?? payload?.longitude

        VStack(spacing: 2) {
            if let lat, let lng {
                let qibla = qiblaBearing(latitude: lat, longitude: lng)
                let heading = compass.heading
                let relative = ((qibla - (heading ?? 0)).truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
                let aligned = heading != nil && (relative < 4 || relative > 356)
                Dial(heading: heading, qibla: qibla, aligned: aligned)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Text("\(Int(qibla.rounded()))°")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(aligned ? Color.accentColor : Color.yellow)
                Text(status(aligned: aligned, heading: heading, relative: relative, payload: payload))
                    .font(.system(size: 10)).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center).lineLimit(2)
            } else {
                Text(payload?.label("qibla", "Qibla") ?? "Qibla").font(.headline)
                Button(payload?.label("useLocationShort", "Use my location") ?? "Use my location") {
                    compass.requestLocation()
                }
                .font(.footnote)
            }
        }
        .padding(.horizontal, 6)
        .onAppear { compass.start() }
        .onDisappear { compass.stop() }
    }

    private func status(aligned: Bool, heading: Double?, relative: Double, payload: WatchPayload?) -> String {
        if aligned { return payload?.label("facingQibla", "You are facing the Qibla") ?? "You are facing the Qibla" }
        guard let _ = heading else {
            return CLLocationManager.headingAvailable()
                ? (payload?.label("compassWaiting", "Waiting for the compass…") ?? "Waiting for the compass…")
                : (payload?.label("compassUnavailable", "No compass on this watch") ?? "No compass on this watch")
        }
        let right = relative <= 180
        let degrees = Int((right ? relative : 360 - relative).rounded())
        let dir = right ? (payload?.label("right", "right") ?? "right") : (payload?.label("left", "left") ?? "left")
        return "\(dir) \(degrees)°"
    }

    struct Dial: View {
        let heading: Double?
        let qibla: Double
        let aligned: Bool

        var body: some View {
            GeometryReader { geo in
                let r = min(geo.size.width, geo.size.height) / 2 - 4
                let c = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                let rot = -(heading ?? 0)
                ZStack {
                    Circle().fill(Color.white.opacity(0.08))
                    Circle().stroke(Color.secondary.opacity(0.5), lineWidth: 1.5)
                    ForEach(0..<12, id: \.self) { i in
                        let d = Double(i) * 30 + rot
                        let len: CGFloat = i == 0 ? 8 : 4
                        Path { p in
                            let a = (d - 90) * Double.pi / 180
                            p.move(to: CGPoint(x: c.x + cos(a) * (r - len), y: c.y + sin(a) * (r - len)))
                            p.addLine(to: CGPoint(x: c.x + cos(a) * r, y: c.y + sin(a) * r))
                        }
                        .stroke(i == 0 ? Color.red : Color.secondary, lineWidth: i == 0 ? 2 : 1)
                    }
                    let qa = (qibla + rot - 90) * Double.pi / 180
                    let rim = CGPoint(x: c.x + cos(qa) * (r - 9), y: c.y + sin(qa) * (r - 9))
                    Path { p in
                        p.move(to: c)
                        p.addLine(to: rim)
                    }
                    .stroke(aligned ? Color.accentColor : Color.yellow, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    Circle().fill(aligned ? Color.accentColor : Color.yellow).frame(width: 16, height: 16).position(rim)
                    Text("🕋").font(.system(size: 10)).position(rim)
                    // Where the watch is pointing.
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(aligned ? Color.accentColor : Color.primary)
                        .position(x: c.x, y: c.y - r + 6)
                }
                .frame(width: r * 2 + 8, height: r * 2 + 8)
                .position(c)
            }
        }
    }
}

final class CompassModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var heading: Double?
    @Published var location: CLLocation?

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.headingFilter = 2
    }

    func start() {
        if CLLocationManager.headingAvailable() {
            manager.startUpdatingHeading()
        }
    }

    func stop() {
        manager.stopUpdatingHeading()
    }

    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let h = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
        DispatchQueue.main.async { self.heading = h }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async { self.location = locations.last }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
}
