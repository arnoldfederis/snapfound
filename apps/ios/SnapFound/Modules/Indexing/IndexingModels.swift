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

extension IndexingState: Equatable {
  static func == (lhs: IndexingState, rhs: IndexingState) -> Bool {
    switch (lhs, rhs) {
    case (.idle, .idle), (.requestingPermission, .requestingPermission),
         (.permissionDenied, .permissionDenied):
      return true
    case (.indexing(let a), .indexing(let b)):
      return a.total == b.total && a.completed == b.completed
    case (.completed(let a), .completed(let b)): return a == b
    case (.freeLimitReached(let a), .freeLimitReached(let b)): return a == b
    case (.paused(let a), .paused(let b)): return a == b
    case (.failed, .failed): return true
    default: return false
    }
  }
}
