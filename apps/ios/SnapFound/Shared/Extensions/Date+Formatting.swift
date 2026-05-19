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
}
