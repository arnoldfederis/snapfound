import Foundation

struct IndexingProgress {
  let total: Int
  let completed: Int
  let currentAssetID: String?

  var fraction: Double {
    guard total > 0 else { return 0 }
    return Double(completed) / Double(total)
  }

  var isComplete: Bool {
    completed >= total && total > 0
  }

  static let idle = IndexingProgress(
    total: 0,
    completed: 0,
    currentAssetID: nil
  )
}

enum IndexingState {
  case idle
  case requestingPermission
  case indexing(IndexingProgress)
  case completed(Int)
  case freeLimitReached(Int)
  case paused(String)
  case failed(Error)
  case permissionDenied
}
