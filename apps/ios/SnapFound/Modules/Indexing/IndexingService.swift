import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class IndexingService {
  static let shared = IndexingService()
  private init() {}

  private(set) var state: IndexingState = .idle
  private(set) var progress: IndexingProgress = .idle

  static let freeIndexLimit = 50

  private let photoService = PhotoLibraryService.shared
  private let ocrService = OCRService.shared
  private let taggingService = TaggingService.shared

  func requestPermissionAndIndex(modelContext: ModelContext, isPro: Bool) async {
    state = .requestingPermission
    let auth = await photoService.requestAuthorization()
    switch auth {
    case .denied, .restricted:
      state = .permissionDenied
    case .notDetermined:
      state = .idle
    case .authorized, .limited:
      await indexScreenshots(modelContext: modelContext, isPro: isPro)
    }
  }

  func indexScreenshots(modelContext: ModelContext, isPro: Bool) async {
    let existingIDs = fetchExistingIDs(modelContext: modelContext)
    let existingCount = existingIDs.count

    // For free tier, cap total indexed (existing + new) at freeIndexLimit.
    let remainingSlots = isPro ? nil : max(0, Self.freeIndexLimit - existingCount)
    if let slots = remainingSlots, slots == 0 {
      state = .completed(existingCount)
      return
    }

    let assets = photoService.fetchScreenshots(limit: remainingSlots)
    let toIndex = assets.filter { !existingIDs.contains($0.localIdentifier) }

    guard !toIndex.isEmpty else {
      state = .completed(existingCount)
      return
    }

    let total = toIndex.count
    progress = IndexingProgress(total: total, completed: 0, currentAssetID: nil)
    state = .indexing(progress)

    var indexed = 0
    for (idx, asset) in toIndex.enumerated() {
      progress = IndexingProgress(
        total: total,
        completed: idx,
        currentAssetID: asset.localIdentifier
      )
      state = .indexing(progress)

      do {
        let record = try await buildRecord(for: asset)
        modelContext.insert(record)
        try? modelContext.save()
        indexed += 1
      } catch {
        #if DEBUG
          print("[IndexingService] skip \(asset.localIdentifier): \(error)")
        #endif
      }
    }

    progress = IndexingProgress(total: total, completed: total, currentAssetID: nil)
    state = .completed(existingCount + indexed)
  }

  func rebuildIndex(modelContext: ModelContext, isPro: Bool) async {
    deleteIndex(modelContext: modelContext)
    await indexScreenshots(modelContext: modelContext, isPro: isPro)
  }

  func deleteIndex(modelContext: ModelContext) {
    try? modelContext.delete(model: ScreenshotRecord.self)
    try? modelContext.save()
    state = .idle
    progress = .idle
  }

  // MARK: - Private

  private func fetchExistingIDs(modelContext: ModelContext) -> Set<String> {
    let descriptor = FetchDescriptor<ScreenshotRecord>()
    let records = (try? modelContext.fetch(descriptor)) ?? []
    return Set(records.map(\.assetID))
  }

  private func buildRecord(for asset: PhotoAsset) async throws -> ScreenshotRecord {
    let imageData = try await photoService.loadFullImageData(for: asset.localIdentifier)

    // OCR runs on OCRService actor's executor (off main thread).
    let ocrResult = try await ocrService.recognizeText(in: imageData)

    let tagResult = taggingService.extractTags(from: ocrResult.text)
    let thumbnailData = makeThumbnail(from: imageData)

    return ScreenshotRecord(
      assetID: asset.localIdentifier,
      creationDate: asset.creationDate,
      ocrText: ocrResult.text,
      tags: tagResult.tags,
      width: asset.pixelWidth,
      height: asset.pixelHeight,
      thumbnailData: thumbnailData
    )
  }

  private nonisolated func makeThumbnail(from data: Data) -> Data? {
    guard
      let image = UIImage(data: data),
      let thumb = image.preparingThumbnail(of: CGSize(width: 300, height: 300))
    else {
      return nil
    }
    return thumb.jpegData(compressionQuality: 0.7)
  }
}
