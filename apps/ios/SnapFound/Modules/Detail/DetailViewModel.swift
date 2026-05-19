import Foundation
import SwiftUI
import UIKit

@MainActor
@Observable
final class DetailViewModel {
  private(set) var fullImage: UIImage?
  private(set) var isLoadingImage = false
  private(set) var loadError: Error?

  private let photoService = PhotoLibraryService.shared

  func loadImage(for record: ScreenshotRecord) async {
    guard fullImage == nil else { return }
    isLoadingImage = true
    loadError = nil
    do {
      let targetSize = CGSize(width: record.width, height: record.height)
      fullImage = try await photoService.loadDisplayImage(
        for: record.assetID,
        targetSize: targetSize
      )
    } catch {
      loadError = error
    }
    isLoadingImage = false
  }

  func shareItems(for record: ScreenshotRecord) -> [Any] {
    var items: [Any] = []
    if let image = fullImage { items.append(image) }
    if !record.ocrText.isEmpty { items.append(record.ocrText) }
    return items
  }
}
