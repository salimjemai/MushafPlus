import SwiftUI
import WidgetKit

/// "Next prayer" complication for every accessory family. It reads the week
/// of prayer times the phone sent (App Group `group.com.salimjemai.mushafplus`)
/// and schedules one timeline entry per prayer, so the face updates by itself
/// without waking the app. `WatchPayload.swift` must be a member of this
/// target as well.
@main
struct MushafWatchComplicationBundle: WidgetBundle {
    var body: some Widget {
        NextPrayerComplication()
    }
}

struct NextPrayerEntry: TimelineEntry {
    let date: Date
    let name: String
    let shortName: String
    let time: Date?
    let place: String?

    static let placeholder = NextPrayerEntry(date: .now, name: "Asr", shortName: "Asr", time: Date().addingTimeInterval(5400), place: "Mushaf+")
    static let empty = NextPrayerEntry(date: .now, name: "Mushaf+", shortName: "—", time: nil, place: nil)
}

struct NextPrayerProvider: TimelineProvider {
    func placeholder(in context: Context) -> NextPrayerEntry { .placeholder }

    func getSnapshot(in context: Context, completion: @escaping (NextPrayerEntry) -> Void) {
        completion(context.isPreview ? .placeholder : entries(from: Date()).first ?? .empty)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NextPrayerEntry>) -> Void) {
        let list = entries(from: Date())
        if list.isEmpty {
            completion(Timeline(entries: [.empty], policy: .after(Date().addingTimeInterval(3600))))
        } else {
            completion(Timeline(entries: list, policy: .atEnd))
        }
    }

    /// One entry now, then one at each prayer time announcing the following
    /// prayer, for as far as the payload goes.
    private func entries(from now: Date) -> [NextPrayerEntry] {
        guard let p = WatchPayload.load() else { return [] }
        let upcoming = p.upcoming(after: now, limit: 40)
        var out: [NextPrayerEntry] = []
        var at = now
        for (name, time) in upcoming {
            let label = p.label(name.rawValue, name.englishName)
            out.append(NextPrayerEntry(date: at, name: label, shortName: String(label.prefix(4)), time: time, place: p.place))
            at = time
        }
        return out
    }
}

struct NextPrayerView: View {
    @Environment(\.widgetFamily) private var family
    let entry: NextPrayerEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 0) {
                    Text(entry.shortName).font(.system(size: 11, weight: .semibold)).minimumScaleFactor(0.7)
                    if let t = entry.time {
                        Text(t, style: .time).font(.system(size: 12, weight: .bold, design: .rounded)).minimumScaleFactor(0.6)
                    } else {
                        Image(systemName: "moon.stars")
                    }
                }
            }
        case .accessoryCorner:
            if let t = entry.time {
                Text(t, style: .time)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .widgetLabel(entry.name)
            } else {
                Image(systemName: "moon.stars").widgetLabel("Mushaf+")
            }
        case .accessoryInline:
            if let t = entry.time {
                Text("\(entry.name) \(t, style: .time)")
            } else {
                Text("Mushaf+")
            }
        default: // .accessoryRectangular
            VStack(alignment: .leading, spacing: 1) {
                HStack {
                    Image(systemName: "moon.stars").font(.caption2)
                    Text(entry.name).font(.headline)
                }
                if let t = entry.time {
                    Text(t, style: .time).font(.system(.title3, design: .rounded)).fontWeight(.bold)
                    Text(t, style: .relative).font(.caption2).foregroundStyle(.secondary)
                } else if let place = entry.place {
                    Text(place).font(.caption2).foregroundStyle(.secondary)
                } else {
                    Text("Open Mushaf+ on iPhone").font(.caption2).foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct NextPrayerComplication: Widget {
    let kind = "NextPrayer"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NextPrayerProvider()) { entry in
            NextPrayerView(entry: entry)
                .containerBackground(for: .widget) { Color.clear }
        }
        .configurationDisplayName("Next prayer")
        .description("The next prayer and its time.")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryInline, .accessoryRectangular])
    }
}
