import SwiftUI

enum GridZoomLevel: Int, CaseIterable {
  /// Grouped by year (coarsest)
  case years = 0
  /// Grouped by month
  case months = 1
  /// 2-column large cells
  case large = 2
  /// 3-column default
  case comfortable = 3
  /// 4-column medium
  case fine = 4
  /// 5-column compact (finest)
  case compact = 5

  var columnCount: Int? {
    switch self {
    case .years, .months: return nil
    case .large: return 2
    case .comfortable: return 3
    case .fine: return 4
    case .compact: return 5
    }
  }

  var spacing: CGFloat {
    switch self {
    case .compact, .fine: return 4
    case .large: return 8
    default: return 10
    }
  }

  var isGrouped: Bool { self == .months || self == .years }

  /// Next coarser level (fewer columns / more grouped).
  var coarser: GridZoomLevel? { GridZoomLevel(rawValue: rawValue - 1) }

  /// Next finer level (more columns / less grouped).
  var finer: GridZoomLevel? { GridZoomLevel(rawValue: rawValue + 1) }
}
