import Foundation

/// Swift port of `lib/core/recitation_matcher.dart`: aligns recognised Arabic
/// speech against the expected Uthmani words. Used by the Apple Watch relay,
/// which recognises the watch's audio on the phone and sends the word
/// statuses back. Keep the two implementations in step.
enum WordStatus: Character {
    case pending = "p", matched = "m", wrong = "w", missed = "x"
}

struct MatchResult {
    var statuses: [WordStatus]
    var heard: [Int: String]
    var nextIndex: Int
    var complete: Bool { nextIndex >= statuses.count }
    var matched: Int { statuses.filter { $0 == .matched }.count }
    var wrong: Int { statuses.filter { $0 == .wrong }.count }

    /// Compact form for WatchConnectivity: one letter per expected word.
    var statusString: String { String(statuses.map { $0.rawValue }) }
}

enum ArabicNormalizer {
    private static let diacritics = try! NSRegularExpression(pattern: "[\\u0610-\\u061A\\u064B-\\u065F\\u0670\\u06D6-\\u06DC\\u06DF-\\u06E4\\u06E7\\u06E8\\u06EA-\\u06ED\\u0640\\u06E9]")
    private static let nonLetters = try! NSRegularExpression(pattern: "[^\\u0621-\\u064A ]")
    private static let spaces = try! NSRegularExpression(pattern: "\\s+")

    private static func replace(_ re: NSRegularExpression, in s: String, with t: String) -> String {
        re.stringByReplacingMatches(in: s, range: NSRange(s.startIndex..., in: s), withTemplate: t)
    }

    /// Same folding as `normalizeForMatch` in Dart: strip tashkeel, unify
    /// alef/yeh/teh-marbuta/hamza forms, keep Arabic letters only.
    static func normalize(_ s: String) -> String {
        var out = replace(diacritics, in: s, with: "")
        let map: [Character: String] = ["ٱ": "ا", "آ": "ا", "أ": "ا", "إ": "ا", "ى": "ي", "ی": "ي", "ة": "ه", "ک": "ك", "ؤ": "و", "ئ": "ي", "ء": ""]
        out = String(out.flatMap { map[$0] ?? String($0) })
        out = replace(nonLetters, in: out, with: " ")
        out = replace(spaces, in: out, with: " ")
        return out.trimmingCharacters(in: .whitespaces)
    }

    static func tokenize(_ s: String) -> [String] {
        normalize(s).split(separator: " ").map(String.init).filter { !$0.isEmpty }
    }
}

/// Normalised Levenshtein similarity in 0...1.
func wordSimilarity(_ a: String, _ b: String) -> Double {
    if a == b { return 1 }
    if a.isEmpty || b.isEmpty { return 0 }
    let x = Array(a.unicodeScalars), y = Array(b.unicodeScalars)
    let n = x.count, m = y.count
    var prev = Array(0...m)
    var cur = [Int](repeating: 0, count: m + 1)
    for i in 1...n {
        cur[0] = i
        for j in 1...m {
            let cost = x[i - 1] == y[j - 1] ? 0 : 1
            cur[j] = min(min(cur[j - 1] + 1, prev[j] + 1), prev[j - 1] + cost)
        }
        swap(&prev, &cur)
    }
    return 1 - Double(prev[m]) / Double(max(n, m))
}

final class RecitationMatcher {
    let original: [String]
    private let expected: [String]
    let strict: Bool

    static let lenientMatchThreshold = 0.72
    static let wrongThreshold = 0.4

    init(words: [String], strict: Bool = true) {
        original = words
        expected = words.map { ArabicNormalizer.tokenize($0).joined() }
        self.strict = strict
    }

    /// Words of a passage from Uthmani ayah texts, dropping empty tokens.
    static func words(of ayahTexts: [String]) -> [String] {
        ayahTexts.flatMap { $0.split(separator: " ").map(String.init).filter { !ArabicNormalizer.tokenize($0).isEmpty } }
    }

    private func isMatch(_ e: String, _ h: String, _ sim: Double) -> Bool {
        if !strict { return sim >= RecitationMatcher.lenientMatchThreshold }
        if e == h { return true }
        return e.replacingOccurrences(of: "ا", with: "") == h.replacingOccurrences(of: "ا", with: "")
    }

    func match(_ heardText: String) -> MatchResult {
        let heard = ArabicNormalizer.tokenize(heardText)
        let n = expected.count, m = heard.count
        if m == 0 || n == 0 {
            return MatchResult(statuses: Array(repeating: .pending, count: n), heard: [:], nextIndex: 0)
        }
        var score = Array(repeating: Array(repeating: 0.0, count: m + 1), count: n + 1)
        var move = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)
        for i in 1...n { score[i][0] = -Double(i); move[i][0] = 1 }
        for j in 1...m { score[0][j] = -Double(j); move[0][j] = 2 }
        var sims = Array(repeating: Array(repeating: 0.0, count: m), count: n)
        var good = Array(repeating: Array(repeating: false, count: m), count: n)
        for i in 1...n {
            for j in 1...m {
                let sim = wordSimilarity(expected[i - 1], heard[j - 1])
                sims[i - 1][j - 1] = sim
                let ok = isMatch(expected[i - 1], heard[j - 1], sim)
                good[i - 1][j - 1] = ok
                let diagGain = ok ? 3.0 : (sim >= RecitationMatcher.wrongThreshold ? 1.0 : -2.0)
                let diag = score[i - 1][j - 1] + diagGain
                let up = score[i - 1][j] - 1
                let left = score[i][j - 1] - 1
                if diag >= up && diag >= left {
                    score[i][j] = diag; move[i][j] = 0
                } else if up >= left {
                    score[i][j] = up; move[i][j] = 1
                } else {
                    score[i][j] = left; move[i][j] = 2
                }
            }
        }
        var bestI = 0
        var best = -Double.infinity
        for i in 0...n {
            let s = score[i][m]
            if s > best || (s == best && i > bestI) { best = s; bestI = i }
        }
        var statuses = Array(repeating: WordStatus.pending, count: n)
        var heardFor: [Int: String] = [:]
        var i = bestI, j = m
        while i > 0 || j > 0 {
            let mv = i == 0 ? 2 : (j == 0 ? 1 : move[i][j])
            if mv == 0 {
                let sim = sims[i - 1][j - 1]
                if good[i - 1][j - 1] {
                    statuses[i - 1] = .matched
                } else if sim >= RecitationMatcher.wrongThreshold {
                    statuses[i - 1] = .wrong
                    heardFor[i - 1] = heard[j - 1]
                } else {
                    statuses[i - 1] = .missed
                }
                i -= 1; j -= 1
            } else if mv == 1 {
                statuses[i - 1] = .missed
                i -= 1
            } else {
                j -= 1
            }
        }
        var next = bestI
        while next > 0 && statuses[next - 1] == .missed {
            statuses[next - 1] = .pending
            next -= 1
        }
        return MatchResult(statuses: statuses, heard: heardFor, nextIndex: next)
    }
}
