import Foundation

struct SearchQuery {
  let originalText: String
  let tokens: [String]
  let expandedTokens: [String]
  let dateFilter: DateFilter?
}

enum DateFilter {
  case today
  case yesterday
  case thisWeek
  case lastWeek
  case thisMonth
  case lastMonth
}

struct SearchResult: Identifiable {
  var id: String {
    record.assetID
  }

  let record: ScreenshotRecord
  let relevanceScore: Double
  let matchedTerms: [String]
}
