import Foundation

struct OCRResult {
  let text: String
  let confidence: Float

  var isEmpty: Bool {
    text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  static let empty = OCRResult(text: "", confidence: 0)
}
