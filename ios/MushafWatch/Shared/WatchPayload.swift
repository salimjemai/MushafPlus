import Foundation

/// What the iPhone app sends (see `lib/data/watch_sync.dart`): a week of
/// prayer times as epoch seconds, a week of verses of the day and the UI
/// labels in the phone's language. Decoded by both the watch app and its
/// complication, so this file belongs to both targets.
struct WatchPayload: Codable {
    static let appGroup = "group.com.salimjemai.mushafplus"
    static let key = "watchPayload"

    var version: Int
    var generatedAt: TimeInterval
    var place: String?
    var timezone: String?
    var latitude: Double?
    var longitude: Double?
    var days: [PrayerDay]
    var verses: [DailyVerse]
    var labels: [String: String]?

    func label(_ key: String, _ fallback: String) -> String {
        labels?[key] ?? fallback
    }

    // MARK: - Storage (App Group, shared with the complication)

    static func load() -> WatchPayload? {
        guard let json = UserDefaults(suiteName: appGroup)?.string(forKey: key) else { return nil }
        return decode(json)
    }

    static func decode(_ json: String) -> WatchPayload? {
        guard let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(WatchPayload.self, from: data)
    }

    static func store(json: String) {
        UserDefaults(suiteName: appGroup)?.set(json, forKey: key)
    }

    // MARK: - Queries

    /// Prayers (not sunrise) still to come, in order, across all days sent.
    func upcoming(after now: Date, limit: Int = 12) -> [(name: PrayerName, time: Date)] {
        var out: [(PrayerName, Date)] = []
        for day in days {
            for (name, time) in day.salahTimes where time > now {
                out.append((name, time))
                if out.count >= limit { return out }
            }
        }
        return out
    }

    func nextPrayer(after now: Date) -> (name: PrayerName, time: Date)? {
        upcoming(after: now, limit: 1).first
    }

    /// The day whose five prayers surround [now]: today, or tomorrow once
    /// Isha has passed.
    func currentDay(at now: Date) -> PrayerDay? {
        days.first { $0.isha > now.timeIntervalSince1970 } ?? days.last
    }

    func verse(on date: Date) -> DailyVerse? {
        let key = DailyVerse.dateKey(date)
        return verses.first { $0.date == key } ?? verses.first
    }

    var isStale: Bool {
        guard let last = days.last else { return true }
        return last.isha < Date().timeIntervalSince1970
    }
}

enum PrayerName: String, CaseIterable, Codable {
    case fajr, sunrise, dhuhr, asr, maghrib, isha

    var isSalah: Bool { self != .sunrise }

    /// English fallback; the payload carries the phone's language.
    var englishName: String {
        switch self {
        case .fajr: return "Fajr"
        case .sunrise: return "Sunrise"
        case .dhuhr: return "Dhuhr"
        case .asr: return "Asr"
        case .maghrib: return "Maghrib"
        case .isha: return "Isha"
        }
    }

    var arabicName: String {
        switch self {
        case .fajr: return "الفجر"
        case .sunrise: return "الشروق"
        case .dhuhr: return "الظهر"
        case .asr: return "العصر"
        case .maghrib: return "المغرب"
        case .isha: return "العشاء"
        }
    }
}

struct PrayerDay: Codable {
    var date: String // yyyy-MM-dd in the place's time zone
    var fajr: TimeInterval
    var sunrise: TimeInterval
    var dhuhr: TimeInterval
    var asr: TimeInterval
    var maghrib: TimeInterval
    var isha: TimeInterval

    func time(of p: PrayerName) -> Date {
        switch p {
        case .fajr: return Date(timeIntervalSince1970: fajr)
        case .sunrise: return Date(timeIntervalSince1970: sunrise)
        case .dhuhr: return Date(timeIntervalSince1970: dhuhr)
        case .asr: return Date(timeIntervalSince1970: asr)
        case .maghrib: return Date(timeIntervalSince1970: maghrib)
        case .isha: return Date(timeIntervalSince1970: isha)
        }
    }

    var salahTimes: [(PrayerName, Date)] {
        PrayerName.allCases.filter { $0.isSalah }.map { ($0, time(of: $0)) }
    }
}

struct DailyVerse: Codable {
    var date: String
    var ref: String // "2:255"
    var surah: String
    var surahArabic: String
    var arabic: String
    var translation: String?

    static func dateKey(_ date: Date) -> String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}

/// Bearing from a point to the Kaaba, degrees clockwise from true north.
func qiblaBearing(latitude: Double, longitude: Double) -> Double {
    let kaabaLat = 21.4225 * Double.pi / 180
    let kaabaLng = 39.8262 * Double.pi / 180
    let lat = latitude * Double.pi / 180
    let dLng = kaabaLng - longitude * Double.pi / 180
    let y = sin(dLng)
    let x = cos(lat) * tan(kaabaLat) - sin(lat) * cos(dLng)
    let deg = atan2(y, x) * 180 / Double.pi
    return (deg + 360).truncatingRemainder(dividingBy: 360)
}

func shortDuration(_ seconds: TimeInterval) -> String {
    let total = max(0, Int(seconds))
    let h = total / 3600
    let m = (total % 3600) / 60
    return h > 0 ? "\(h)h \(m)m" : "\(m)m"
}
