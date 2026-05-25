import Foundation

struct TaggingService {
  static let shared = TaggingService()
  private init() {}

  nonisolated func extractTags(from text: String, width: Int = 0, height: Int = 0) -> TagResult {
    var tags: Set<String> = []
    let lower = text.lowercased()
    let containsPrice = hasPrice(in: text)

    if hasURL(in: text) { tags.insert("url") }
    if hasError(in: lower) { tags.insert("error") }
    if containsPrice { tags.insert("price") }
    if hasCode(in: text) { tags.insert("code") }
    if hasNotification(in: lower) { tags.insert("notification") }
    if hasMessage(in: lower) { tags.insert("message") }
    if hasSettings(in: lower) { tags.insert("settings") }
    if hasLocation(in: lower) { tags.insert("map") }
    if hasHealth(in: lower) { tags.insert("health") }
    if hasMedia(in: lower) { tags.insert("media") }
    if hasSocial(in: lower) { tags.insert("social") }
    if hasDate(in: lower) { tags.insert("date") }
    if hasReceipt(in: lower, containsPrice: containsPrice) { tags.insert("receipt") }
    if hasTravel(in: lower) { tags.insert("travel") }
    if hasShopping(in: lower) { tags.insert("shopping") }
    if hasDocument(in: lower) { tags.insert("document") }
    if hasMeme(in: lower) { tags.insert("meme") }
    if hasFinance(in: lower, containsPrice: containsPrice) { tags.insert("finance") }
    if hasLogin(in: lower) { tags.insert("login") }
    if hasFood(in: lower) { tags.insert("food") }
    if hasCalendar(in: lower) { tags.insert("calendar") }
    if hasAppContext(in: lower) || isLikelyAppScreenshot(width: width, height: height) {
      tags.insert("app")
    }

    let appTags = detectApps(in: lower)
    if !appTags.isEmpty { tags.insert("app") }
    tags.formUnion(appTags)

    // TODO: Add FoundationModels SystemLanguageModel guided generation for richer local descriptions and tags when available.

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

  private nonisolated func hasReceipt(in text: String, containsPrice: Bool) -> Bool {
    let keywords = [
      "receipt", "invoice", "subtotal", "total", "tax", "tip", "paid", "payment",
      "charged", "transaction", "order #", "order number", "merchant",
    ]
    return keywords.count(where: { text.contains($0) }) >= 2
      || (containsPrice && containsAny(["total", "paid", "order", "invoice"], in: text))
  }

  private nonisolated func hasTravel(in text: String) -> Bool {
    let keywords = [
      "flight", "airline", "boarding", "gate", "terminal", "hotel", "booking",
      "reservation", "check-in", "checkout", "passport", "itinerary", "trip",
      "departure", "arrival", "airport", "train", "uber", "lyft",
    ]
    return containsAny(keywords, in: text)
  }

  private nonisolated func hasShopping(in text: String) -> Bool {
    let keywords = [
      "order", "cart", "checkout", "shipping", "delivery", "delivered", "tracking",
      "purchase", "shop", "store", "seller", "amazon", "etsy", "lazada", "shopee",
      "confirmation", "return", "refund",
    ]
    return containsAny(keywords, in: text)
  }

  private nonisolated func hasDocument(in text: String) -> Bool {
    let keywords = [
      "pdf", "document", "contract", "agreement", "statement", "form", "policy",
      "terms", "notes", "memo", "page", "signature", "certificate", "report",
    ]
    return containsAny(keywords, in: text)
  }

  private nonisolated func hasMeme(in text: String) -> Bool {
    let keywords = [
      "meme", "lol", "lmao", "haha", "when you", "me when", "relatable",
      "caption", "reaction", "funny",
    ]
    return containsAny(keywords, in: text)
  }

  private nonisolated func hasFinance(in text: String, containsPrice: Bool) -> Bool {
    let keywords = [
      "bank", "balance", "card", "credit", "debit", "budget", "stock", "crypto",
      "portfolio", "payment", "invoice", "receipt", "transfer", "deposit",
      "withdrawal", "interest", "apr", "loan", "statement",
    ]
    return containsPrice || containsAny(keywords, in: text)
  }

  private nonisolated func hasLogin(in text: String) -> Bool {
    let keywords = [
      "login", "log in", "sign in", "password", "passcode", "verification",
      "one-time", "otp", "2fa", "authenticator", "security code", "reset password",
      "username", "email address",
    ]
    return containsAny(keywords, in: text)
  }

  private nonisolated func hasFood(in text: String) -> Bool {
    let keywords = [
      "restaurant", "menu", "food", "meal", "coffee", "drink", "delivery",
      "pickup", "doordash", "ubereats", "grubhub", "recipe", "calories",
      "breakfast", "lunch", "dinner",
    ]
    return containsAny(keywords, in: text)
  }

  private nonisolated func hasCalendar(in text: String) -> Bool {
    let keywords = [
      "calendar", "meeting", "event", "appointment", "schedule", "agenda",
      "invite", "zoom", "teams", "google meet", "reminder",
    ]
    return containsAny(keywords, in: text) || hasDate(in: text)
  }

  private nonisolated func hasAppContext(in text: String) -> Bool {
    let keywords = [
      "app", "settings", "profile", "account", "tab", "button", "screen",
      "notification", "permission", "privacy", "share", "save", "edit",
    ]
    return containsAny(keywords, in: text)
  }

  private nonisolated func isLikelyAppScreenshot(width: Int, height: Int) -> Bool {
    guard width > 0, height > 0 else { return false }
    let aspectRatio = Double(max(width, height)) / Double(min(width, height))
    return aspectRatio >= 1.6
  }

  private nonisolated func containsAny(_ keywords: [String], in text: String) -> Bool {
    keywords.contains { text.contains($0) }
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
