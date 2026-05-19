import Foundation

struct TaggingService {
  static let shared = TaggingService()
  private init() {}

  nonisolated func extractTags(from text: String) -> TagResult {
    guard !text.isEmpty else { return TagResult(tags: []) }

    var tags: Set<String> = []
    let lower = text.lowercased()

    if hasURL(in: text) { tags.insert("url") }
    if hasError(in: lower) { tags.insert("error") }
    if hasPrice(in: text) { tags.insert("price") }
    if hasCode(in: text) { tags.insert("code") }
    if hasNotification(in: lower) { tags.insert("notification") }
    if hasMessage(in: lower) { tags.insert("message") }
    if hasSettings(in: lower) { tags.insert("settings") }
    if hasLocation(in: lower) { tags.insert("map") }
    if hasHealth(in: lower) { tags.insert("health") }
    if hasMedia(in: lower) { tags.insert("media") }
    if hasSocial(in: lower) { tags.insert("social") }
    if hasDate(in: lower) { tags.insert("date") }

    tags.formUnion(detectApps(in: lower))

    return TagResult(tags: Array(tags).sorted())
  }

  private nonisolated func hasURL(in text: String) -> Bool {
    guard
      let detector = try? NSDataDetector(
        types: NSTextCheckingResult.CheckingType.link.rawValue)
    else {
      return false
    }
    let range = NSRange(text.startIndex..., in: text)
    return detector.numberOfMatches(in: text, range: range) > 0
  }

  private nonisolated func hasError(in text: String) -> Bool {
    let keywords = [
      "error",
      "failed",
      "crash",
      "exception",
      "warning",
      "fatal",
      "undefined",
      "null",
      "404",
      "500",
      "403",
      "401",
      "invalid",
    ]
    return keywords.contains { text.contains($0) }
  }

  private nonisolated func hasPrice(in text: String) -> Bool {
    let pattern = "[$€£¥₩]\\s?\\d|\\d+\\.\\d{2}"
    return text.range(of: pattern, options: .regularExpression) != nil
  }

  private nonisolated func hasCode(in text: String) -> Bool {
    let indicators = [
      "func ",
      "class ",
      "var ",
      "let ",
      "import ",
      "return ",
      "struct ",
      "enum ",
      "extension ",
      "{}",
      "() {",
      "// ",
    ]
    return indicators.count(where: { text.contains($0) }) >= 2
  }

  private nonisolated func hasNotification(in text: String) -> Bool {
    let keywords = [
      "notification",
      "alert",
      "badge",
      "push",
      "remind",
      "missed call",
      "new message",
      "unread",
    ]
    return keywords.contains { text.contains($0) }
  }

  private nonisolated func hasMessage(in text: String) -> Bool {
    let keywords = [
      "message",
      "chat",
      "reply",
      "send",
      "dm",
      "inbox",
      "from:",
      "to:",
      "subject:",
      "imessage",
      "whatsapp",
      "telegram",
    ]
    return keywords.contains { text.contains($0) }
  }

  private nonisolated func hasSettings(in text: String) -> Bool {
    let keywords = [
      "settings",
      "preferences",
      "toggle",
      "enable",
      "disable",
      "permission",
      "privacy",
      "account",
      "profile",
      "configuration",
    ]
    return keywords.contains { text.contains($0) }
  }

  private nonisolated func hasLocation(in text: String) -> Bool {
    let keywords = [
      "map",
      "location",
      "directions",
      "navigate",
      "miles",
      " km",
      "route",
      "gps",
      "address",
      "street",
    ]
    return keywords.contains { text.contains($0) }
  }

  private nonisolated func hasHealth(in text: String) -> Bool {
    let keywords = [
      "health",
      "steps",
      "heart rate",
      "calories",
      "sleep",
      "workout",
      "bpm",
      "activity",
      "exercise",
      "water",
      "weight",
    ]
    return keywords.contains { text.contains($0) }
  }

  private nonisolated func hasMedia(in text: String) -> Bool {
    let keywords = [
      "now playing",
      "podcast",
      "episode",
      "album",
      "song",
      "artist",
      "playlist",
      "stream",
      "watch",
      "video",
    ]
    return keywords.count(where: { text.contains($0) }) >= 1
  }

  private nonisolated func hasSocial(in text: String) -> Bool {
    let keywords = [
      "followers",
      "following",
      "retweet",
      "likes",
      "comments",
      "shares",
      "story",
      "reel",
      "post",
      "profile",
    ]
    return keywords.count(where: { text.contains($0) }) >= 2
  }

  private nonisolated func hasDate(in text: String) -> Bool {
    // Detects common date patterns
    let pattern =
      "\\b(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)|\\d{1,2}/\\d{1,2}|\\d{4}-\\d{2}-\\d{2}"
    return text.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
  }

  private nonisolated func detectApps(in text: String) -> [String] {
    let appMap: [String: String] = [
      "safari": "safari", "maps": "maps", "messages": "messages",
      "facetime": "facetime", "mail": "mail", "notes": "notes",
      "calendar": "calendar", "xcode": "xcode", "slack": "slack",
      "notion": "notion", "figma": "figma", "twitter": "twitter",
      "instagram": "instagram", "youtube": "youtube", "spotify": "spotify",
      "netflix": "netflix", "github": "github", "linear": "linear",
      "discord": "discord", "telegram": "telegram",
    ]
    return appMap.compactMap { text.contains($0.key) ? $0.value : nil }
  }
}
