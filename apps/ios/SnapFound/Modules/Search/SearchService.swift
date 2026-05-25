import Foundation

@Observable
final class SearchService {
  private(set) var results: [SearchResult] = []
  private(set) var isSearching = false

  private let synonyms: [String: [String]] = [
    "error": ["bug", "crash", "fail", "issue", "problem", "exception", "warning"],
    "message": ["text", "chat", "dm", "sms", "imessage", "whatsapp"],
    "code": ["programming", "swift", "python", "javascript", "xcode", "terminal"],
    "money": ["price", "cost", "payment", "dollar", "usd", "buy", "purchase", "paid", "finance"],
    "finance": ["bank", "balance", "budget", "payment", "invoice", "receipt", "money"],
    "map": ["location", "directions", "navigate", "gps", "address", "route"],
    "settings": ["preferences", "configuration", "options", "toggle", "privacy"],
    "note": ["notes", "memo", "reminder", "todo", "task", "meeting"],
    "document": ["pdf", "form", "contract", "statement", "report", "notes"],
    "photo": ["image", "picture", "screenshot"],
    "app": ["application", "settings", "profile", "account", "screen"],
    "social": ["twitter", "instagram", "facebook", "tiktok", "linkedin"],
    "health": ["steps", "calories", "workout", "heart", "sleep", "fitness"],
    "music": ["spotify", "apple music", "song", "album", "playlist", "podcast"],
    "wifi": ["wi-fi", "wireless", "network", "ssid", "password"],
    "password": ["login", "passcode", "credential", "wifi", "wi-fi"],
    "login": ["sign in", "password", "passcode", "verification", "otp", "2fa"],
    "otp": ["verification", "one-time", "2fa", "authenticator", "verify", "code"],
    "tracking": ["shipment", "delivery", "shipped", "package", "parcel", "courier"],
    "order": ["invoice", "confirmation", "purchase", "receipt", "total", "shopping"],
    "receipt": ["invoice", "payment", "amount", "charged", "total", "order"],
    "shopping": ["order", "cart", "checkout", "shipping", "delivery", "receipt"],
    "travel": ["flight", "hotel", "booking", "reservation", "itinerary", "trip"],
    "flight": ["airline", "boarding", "departure", "arrival", "gate", "terminal", "travel"],
    "hotel": ["reservation", "check-in", "checkout", "booking", "accommodation", "travel"],
    "meeting": ["calendar", "agenda", "minutes", "notes", "call", "zoom", "teams"],
    "calendar": ["meeting", "event", "appointment", "schedule", "reminder"],
    "food": ["restaurant", "menu", "meal", "coffee", "delivery", "recipe"],
    "meme": ["funny", "lol", "reaction", "caption", "relatable"],
  ]

  private let stopWords: Set<String> = [
    "a", "an", "and", "about", "by", "for", "from", "in", "like", "me", "my",
    "of", "on", "or", "the", "to", "with", "last", "this",
  ]

  func search(query: String, in records: [ScreenshotRecord]) {
    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
      results = []
      return
    }

    isSearching = true
    defer { isSearching = false }

    let parsed = parseQuery(trimmed)

    results =
      records
      .compactMap { record -> SearchResult? in
        let (score, terms) = score(record: record, query: parsed)
        guard score > 0 else { return nil }
        return SearchResult(
          record: record,
          relevanceScore: score,
          matchedTerms: terms
        )
      }
      .sorted { $0.relevanceScore > $1.relevanceScore }
  }

  func clear() {
    results = []
  }

  // MARK: - Private

  private func parseQuery(_ raw: String) -> SearchQuery {
    let lower = raw.lowercased()
    // Normalise wi-fi/wifi before tokenising
    let normalised =
      normalizeForSearch(lower)
      .replacingOccurrences(of: "verification code", with: "otp")
      .replacingOccurrences(of: "tracking number", with: "tracking")
      .replacingOccurrences(of: "order confirmation", with: "order")

    let tokens =
      normalised
      .components(separatedBy: CharacterSet.alphanumerics.inverted)
      .filter { !$0.isEmpty && $0.count > 1 && !stopWords.contains($0) }

    var expanded = Set(tokens)
    for token in tokens {
      if let syns = synonyms[token] {
        for syn in syns { expanded.insert(syn) }
      }
      for (key, syns) in synonyms where syns.contains(token) {
        expanded.insert(key)
        for syn in syns { expanded.insert(syn) }
      }
    }

    return SearchQuery(
      originalText: raw,
      tokens: tokens,
      expandedTokens: Array(expanded),
      dateFilter: detectDateFilter(in: lower)
    )
  }

  private func detectDateFilter(in text: String) -> DateFilter? {
    if text.contains("today") { return .today }
    if text.contains("yesterday") { return .yesterday }
    if text.contains("last week") { return .lastWeek }
    if text.contains("last month") { return .lastMonth }
    if text.contains("this week") || text == "week" { return .thisWeek }
    if text.contains("this month") || text == "month" { return .thisMonth }
    return nil
  }

  private func score(record: ScreenshotRecord, query: SearchQuery) -> (Double, [String]) {
    var score = 0.0
    var matched: Set<String> = []

    let searchableText = normalizeForSearch(record.ocrText)
    let tagsLower = Set(record.tags.map { normalizeForSearch($0) })

    // TODO: Semantic embeddings can replace this keyword expansion with local vector search.

    // Date filter
    if let filter = query.dateFilter {
      guard matchesDate(record.creationDate, filter: filter) else {
        return (0, [])
      }
      score += 3.0
      matched.insert("date")
    }

    // Exact phrase match (highest weight)
    if searchableText.contains(normalizeForSearch(query.originalText)) {
      score += 6.0
    }

    // Original token matching in OCR (higher weight)
    for token in query.tokens {
      if searchableText.contains(token) {
        score += token.count > 4 ? 3.0 : 2.0
        matched.insert(token)
      }
    }

    // Original token matching in tags (highest per-token weight)
    for token in query.tokens {
      if tagsLower.contains(token) {
        score += 4.0
        matched.insert(token)
      }
    }

    // Synonym-expanded tokens (lower weight than original query terms)
    let synonymTokens = query.expandedTokens.filter { !query.tokens.contains($0) }
    for token in synonymTokens {
      let normalizedToken = normalizeMatchTerm(token)
      if searchableText.contains(normalizedToken) {
        score += token.count > 4 ? 1.0 : 0.5
        matched.insert(normalizedToken)
      }
      if tagsLower.contains(normalizedToken) {
        score += 1.5
        matched.insert(normalizedToken)
      }
    }

    // Recency boost
    let daysSinceCapture = Date().timeIntervalSince(record.creationDate) / 86400
    if daysSinceCapture < 7 { score += 0.5 }

    return (score, orderedMatchedTerms(from: matched, query: query))
  }

  private func normalizeForSearch(_ text: String) -> String {
    text
      .lowercased()
      .replacingOccurrences(of: "wi-fi", with: "wifi")
  }

  private func normalizeMatchTerm(_ term: String) -> String {
    normalizeForSearch(term)
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private func orderedMatchedTerms(from matched: Set<String>, query: SearchQuery) -> [String] {
    var ordered: [String] = []
    var seen: Set<String> = []

    for term in query.tokens + query.expandedTokens {
      let normalized = normalizeMatchTerm(term)
      guard matched.contains(normalized), seen.insert(normalized).inserted else { continue }
      ordered.append(normalized)
    }

    for term in matched.sorted() where seen.insert(term).inserted {
      ordered.append(term)
    }

    return ordered
  }

  private func matchesDate(_ date: Date, filter: DateFilter) -> Bool {
    let cal = Calendar.current
    switch filter {
    case .today:
      return cal.isDateInToday(date)
    case .yesterday:
      return cal.isDateInYesterday(date)
    case .thisWeek:
      return cal.isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
    case .lastWeek:
      guard
        let startOfThisWeek = cal.dateInterval(of: .weekOfYear, for: Date())?.start,
        let startOfLastWeek = cal.date(byAdding: .weekOfYear, value: -1, to: startOfThisWeek)
      else { return false }
      return date >= startOfLastWeek && date < startOfThisWeek
    case .thisMonth:
      return cal.isDate(date, equalTo: Date(), toGranularity: .month)
    case .lastMonth:
      guard
        let startOfThisMonth = cal.dateInterval(of: .month, for: Date())?.start,
        let startOfLastMonth = cal.date(byAdding: .month, value: -1, to: startOfThisMonth)
      else { return false }
      return date >= startOfLastMonth && date < startOfThisMonth
    }
  }
}
