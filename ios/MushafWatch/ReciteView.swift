import SwiftUI

/// "Recite & check" on the wrist: choose a surah, tap the microphone and
/// recite from memory. Words turn green as they are heard, red when wrong
/// (with a haptic), gold for the one expected next.
struct ReciteView: View {
    @EnvironmentObject private var store: WatchStore
    @ObservedObject private var session = WatchStore.shared.recite
    @AppStorage("reciteSurah") private var surah = 1
    @State private var picking = false

    var body: some View {
        let p = store.payload
        VStack(spacing: 4) {
            if session.state == .listening || session.state == .starting {
                listening(p)
            } else {
                idle(p)
            }
        }
        .padding(.horizontal, 4)
        .sheet(isPresented: $picking) {
            SurahPicker(selected: $surah)
        }
        .onDisappear { if session.isActive { session.stop() } }
    }

    @ViewBuilder
    private func idle(_ p: WatchPayload?) -> some View {
        Text(p?.label("reciteAndCheck", "Recite & check") ?? "Recite & check")
            .font(.system(size: 10)).foregroundStyle(.secondary)
        Button {
            picking = true
        } label: {
            HStack(spacing: 2) {
                Text(SurahNames.arabic(surah)).font(.system(size: 15, weight: .semibold)).foregroundStyle(.tint).lineLimit(1)
                Image(systemName: "chevron.up.chevron.down").font(.system(size: 9)).foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
        Button {
            session.start(surah: surah)
        } label: {
            Image(systemName: "mic.fill").font(.system(size: 24))
        }
        .frame(width: 56, height: 56)
        .buttonStyle(.borderedProminent)
        .clipShape(Circle())
        switch session.state {
        case .failed(let reason):
            Text(failureText(reason, p)).font(.system(size: 8)).foregroundStyle(.red).multilineTextAlignment(.center).lineLimit(3)
        default:
            if session.statuses.contains(where: { $0 != "p" }) {
                Text("\(session.statuses.filter { $0 == "m" }.count)/\(session.next) · \(session.wrongCount) ✗")
                    .font(.system(size: 10)).foregroundStyle(.secondary)
            } else {
                Text(p?.label("tapMicToStart", "Tap the microphone and start reciting") ?? "Tap the microphone and start reciting")
                    .font(.system(size: 8)).foregroundStyle(.secondary).multilineTextAlignment(.center).lineLimit(2)
            }
        }
    }

    @ViewBuilder
    private func listening(_ p: WatchPayload?) -> some View {
        let cursorAyah = session.next < session.ayahOf.count ? session.ayahOf[session.next] : max(0, session.keys.count - 1)
        HStack {
            Image(systemName: session.state == .listening ? "mic.fill" : "hourglass")
                .font(.system(size: 10)).foregroundStyle(session.state == .listening ? Color.accentColor : Color.secondary)
            Text(session.keys.indices.contains(cursorAyah) ? session.keys[cursorAyah] : "")
                .font(.system(size: 10)).foregroundStyle(.secondary)
            Spacer()
            Text("\(session.wrongCount) ✗").font(.system(size: 10)).foregroundStyle(session.wrongCount > 0 ? .red : .secondary)
        }
        ScrollView {
            Text(ayahText(cursorAyah))
                .font(.system(size: 15))
                .multilineTextAlignment(.center)
                .environment(\.layoutDirection, .rightToLeft)
                .lineSpacing(4)
        }
        Button {
            session.stop()
        } label: {
            Label(p?.label("stop", "Stop") ?? "Stop", systemImage: "stop.fill").font(.system(size: 10))
        }
        .buttonStyle(.bordered)
        .controlSize(.mini)
    }

    private func ayahText(_ ayah: Int) -> AttributedString {
        var out = AttributedString()
        for i in session.words.indices where session.ayahOf.indices.contains(i) && session.ayahOf[i] == ayah {
            var piece = AttributedString(session.words[i] + " ")
            let status = session.statuses.indices.contains(i) ? session.statuses[i] : "p"
            switch status {
            case "m": piece.foregroundColor = .green
            case "w": piece.foregroundColor = .red
            case "x": piece.foregroundColor = .orange
            default: piece.foregroundColor = i == session.next ? .yellow : .primary
            }
            if i == session.next { piece.font = .system(size: 15, weight: .bold) }
            out.append(piece)
        }
        return out
    }

    private func failureText(_ reason: String, _ p: WatchPayload?) -> String {
        switch reason {
        case "phone-unreachable": return "Open Mushaf+ on your iPhone and keep it nearby."
        case "mic-denied": return "Allow the microphone for Mushaf+ in the Watch app settings."
        case "speech-denied": return "Allow speech recognition for Mushaf+ on the iPhone."
        case "speech-unavailable": return "Arabic speech recognition is not available on the iPhone right now."
        default: return reason
        }
    }
}

struct SurahPicker: View {
    @Binding var selected: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List(1...114, id: \.self) { n in
            Button {
                selected = n
                dismiss()
            } label: {
                HStack {
                    Text("\(n)").font(.system(size: 10)).foregroundStyle(.secondary).frame(width: 22, alignment: .leading)
                    Text(SurahNames.arabic(n))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(n == selected ? Color.accentColor : Color.primary)
                        .environment(\.layoutDirection, .rightToLeft)
                    Spacer()
                    if n == selected { Image(systemName: "checkmark").font(.system(size: 10)) }
                }
            }
        }
    }
}

/// The 114 surah names, so the picker needs no data from the phone.
enum SurahNames {
    static let arabic: [String] = [
        "الفاتحة", "البقرة", "آل عمران", "النساء", "المائدة", "الأنعام", "الأعراف", "الأنفال", "التوبة", "يونس",
        "هود", "يوسف", "الرعد", "إبراهيم", "الحجر", "النحل", "الإسراء", "الكهف", "مريم", "طه",
        "الأنبياء", "الحج", "المؤمنون", "النور", "الفرقان", "الشعراء", "النمل", "القصص", "العنكبوت", "الروم",
        "لقمان", "السجدة", "الأحزاب", "سبأ", "فاطر", "يس", "الصافات", "ص", "الزمر", "غافر",
        "فصلت", "الشورى", "الزخرف", "الدخان", "الجاثية", "الأحقاف", "محمد", "الفتح", "الحجرات", "ق",
        "الذاريات", "الطور", "النجم", "القمر", "الرحمن", "الواقعة", "الحديد", "المجادلة", "الحشر", "الممتحنة",
        "الصف", "الجمعة", "المنافقون", "التغابن", "الطلاق", "التحريم", "الملك", "القلم", "الحاقة", "المعارج",
        "نوح", "الجن", "المزمل", "المدثر", "القيامة", "الإنسان", "المرسلات", "النبأ", "النازعات", "عبس",
        "التكوير", "الانفطار", "المطففين", "الانشقاق", "البروج", "الطارق", "الأعلى", "الغاشية", "الفجر", "البلد",
        "الشمس", "الليل", "الضحى", "الشرح", "التين", "العلق", "القدر", "البينة", "الزلزلة", "العاديات",
        "القارعة", "التكاثر", "العصر", "الهمزة", "الفيل", "قريش", "الماعون", "الكوثر", "الكافرون", "النصر",
        "المسد", "الإخلاص", "الفلق", "الناس",
    ]

    static func arabic(_ n: Int) -> String {
        (1...114).contains(n) ? arabic[n - 1] : ""
    }
}
