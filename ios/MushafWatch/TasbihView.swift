import SwiftUI
import WatchKit

/// Dhikr counter: tap anywhere (or turn the Digital Crown) to count, with a
/// haptic at every 33 and the phrase moving on: SubhanAllah, Alhamdulillah,
/// Allahu Akbar. Long-press to start again.
struct TasbihView: View {
    @EnvironmentObject private var store: WatchStore
    @AppStorage("tasbihCount") private var count = 0
    @State private var crown = 0.0

    private static let adhkar = ["سُبْحَانَ ٱللَّٰهِ", "ٱلْحَمْدُ لِلَّٰهِ", "ٱللَّٰهُ أَكْبَرُ"]

    var body: some View {
        let phase = (count / 33) % Self.adhkar.count
        let inPhase = count % 33
        ZStack {
            Circle()
                .trim(from: 0, to: inPhase == 0 && count > 0 ? 1 : Double(inPhase) / 33)
                .stroke(Color.yellow, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .padding(3)
            Circle().stroke(Color.white.opacity(0.08), lineWidth: 3).padding(3)
            VStack(spacing: 2) {
                Text(store.payload?.label("tasbih", "Tasbih") ?? "Tasbih")
                    .font(.system(size: 10)).foregroundStyle(.secondary)
                Text(Self.adhkar[phase])
                    .font(.system(size: 17, weight: .semibold)).foregroundStyle(.tint)
                    .environment(\.layoutDirection, .rightToLeft)
                Text("\(count)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
                Text("\(inPhase) / 33").font(.system(size: 10)).foregroundStyle(.yellow)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { tap() }
        .onLongPressGesture { reset() }
        .focusable()
        .digitalCrownRotation($crown, from: 0, through: 10_000, by: 1, sensitivity: .medium, isContinuous: true, isHapticFeedbackEnabled: false)
        .onChange(of: crown) { _, value in
            // One tick per crown step.
            let steps = Int(value)
            if steps != count {
                if steps > count { count = steps; feedback() } else { crown = Double(count) }
            }
        }
        .onAppear { crown = Double(count) }
    }

    private func tap() {
        count += 1
        crown = Double(count)
        feedback()
    }

    private func feedback() {
        WKInterfaceDevice.current().play(count % 33 == 0 ? .success : .click)
    }

    private func reset() {
        count = 0
        crown = 0
        WKInterfaceDevice.current().play(.retry)
    }
}
