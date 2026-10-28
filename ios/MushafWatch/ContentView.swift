import SwiftUI

/// Vertically paged like the built-in watch apps: prayer times, Qibla,
/// tasbih, verse of the day, recitation check.
struct ContentView: View {
    @EnvironmentObject private var store: WatchStore

    var body: some View {
        TabView {
            PrayerView()
            QiblaView()
            TasbihView()
            VerseView()
            ReciteView()
        }
        .tabViewStyle(.verticalPage)
        .onAppear { store.refreshFromPhone() }
    }
}

// MARK: - Prayer times

struct PrayerView: View {
    @EnvironmentObject private var store: WatchStore

    var body: some View {
        TimelineView(.periodic(from: .now, by: 30)) { context in
            content(now: context.date)
        }
    }

    @ViewBuilder
    private func content(now: Date) -> some View {
        if let p = store.payload, let next = p.nextPrayer(after: now), let day = p.currentDay(at: now) {
            ScrollView {
                VStack(spacing: 2) {
                    if let place = p.place {
                        Text(place).font(.footnote).foregroundStyle(.secondary).lineLimit(1)
                    }
                    Text(p.label(next.name.rawValue, next.name.englishName))
                        .font(.headline).foregroundStyle(.tint)
                    Text(p.label("in", "in") + " " + shortDuration(next.time.timeIntervalSince(now)))
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .minimumScaleFactor(0.6).lineLimit(1)
                    Text(next.time, style: .time).font(.footnote).foregroundStyle(.secondary)
                    Divider().padding(.vertical, 4)
                    ForEach(day.salahTimes, id: \.0) { name, time in
                        HStack {
                            Text(p.label(name.rawValue, name.englishName))
                            Spacer()
                            Text(time, style: .time)
                        }
                        .font(.footnote)
                        .fontWeight(name == next.name ? .bold : .regular)
                        .foregroundStyle(name == next.name ? Color.accentColor : (time < now ? Color.secondary : Color.primary))
                    }
                }
                .padding(.horizontal, 4)
            }
            .navigationTitle(p.label("prayerTimes", "Prayer times"))
        } else {
            VStack(spacing: 8) {
                Image(systemName: "iphone.and.arrow.forward").font(.title2).foregroundStyle(.tint)
                Text(store.payload?.label("watchOpenPhone", "Open Mushaf+ on your iPhone and set a prayer location.")
                     ?? "Open Mushaf+ on your iPhone and set a prayer location.")
                    .font(.footnote).multilineTextAlignment(.center)
                Button("Refresh") { store.refreshFromPhone() }.font(.footnote)
            }
            .padding()
        }
    }
}

// MARK: - Verse of the day

struct VerseView: View {
    @EnvironmentObject private var store: WatchStore

    var body: some View {
        ScrollView {
            if let p = store.payload, let v = p.verse(on: Date()) {
                VStack(spacing: 6) {
                    Text(p.label("verseOfTheDay", "VERSE OF THE DAY"))
                        .font(.system(size: 10, weight: .bold)).tracking(1.2).foregroundStyle(.tint)
                    Text("\(v.surah) \(v.ref)").font(.footnote).foregroundStyle(.secondary)
                    Text(v.arabic)
                        .font(.system(size: 18))
                        .multilineTextAlignment(.center)
                        .environment(\.layoutDirection, .rightToLeft)
                        .lineSpacing(6)
                    if let t = v.translation {
                        Text(t).font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 4)
            } else {
                Text("Open Mushaf+ on your iPhone once to receive the verse of the day.")
                    .font(.footnote).multilineTextAlignment(.center).padding()
            }
        }
    }
}
