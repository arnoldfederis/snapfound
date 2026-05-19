import Foundation
import SwiftData

@Model
final class ScreenshotRecord {
  @Attribute(.unique) var assetID: String
  var creationDate: Date
  var ocrText: String
  var tags: [String]
  var width: Int
  var height: Int
  var thumbnailData: Data?
  var indexedAt: Date

  init(
    assetID: String,
    creationDate: Date,
    ocrText: String,
    tags: [String],
    width: Int,
    height: Int,
    thumbnailData: Data?
  ) {
    self.assetID = assetID
    self.creationDate = creationDate
    self.ocrText = ocrText
    self.tags = tags
    self.width = width
    self.height = height
    self.thumbnailData = thumbnailData
    indexedAt = Date()
  }
}
