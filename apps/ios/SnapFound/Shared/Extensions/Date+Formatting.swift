import Foundation

extension Date {
  var relativeDisplay: String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .abbreviated
    return formatter.localizedString(for: self, relativeTo: Date())
  }

  var shortDisplay: String {
    formatted(.dateTime.month(.abbreviated).day().year())
  }

  var mediumDisplay: String {
    formatted(.dateTime.month(.wide).day().year().hour().minute())
  }
  
  func smartDisplayString(now: Date = Date(), calendar: Calendar = .current) -> String {
    let isSameYear = calendar.component(.year, from: self) == calendar.component(.year, from: now)
    
    // Is date in the same week as 'now'?
    if calendar.isDate(self, equalTo: now, toGranularity: .weekOfYear) &&
        calendar.isDate(self, equalTo: now, toGranularity: .year) {
      // Weekday name (e.g., "Monday")
      let weekdayFormatter = DateFormatter()
      weekdayFormatter.locale = .current
      weekdayFormatter.calendar = calendar
      weekdayFormatter.dateFormat = "EEEE"
      return weekdayFormatter.string(from: self)
    }
    
    let formatter = DateFormatter()
    formatter.locale = .current
    formatter.calendar = calendar
    
    if isSameYear {
      // "May 16"
      formatter.setLocalizedDateFormatFromTemplate("MMM d")
    } else {
      // "May 16, 2025"
      formatter.setLocalizedDateFormatFromTemplate("MMM d, yyyy")
    }
    return formatter.string(from: self)
  }
  
  // e.g., "01:00 PM"
  static let smartTimeAMPMFormatter: DateFormatter = {
    let df = DateFormatter()
    df.locale = .current
    df.dateFormat = "hh:mm a" // 12-hour with leading zero hour
    return df
  }()
}
