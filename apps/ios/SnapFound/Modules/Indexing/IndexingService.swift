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
      state = .freeLimitReached(existingCount)
      return
    }

    let assets = photoService.fetchScreenshots()
    let newAssets = assets.filter { !existingIDs.contains($0.localIdentifier) }
    let toIndex: [PhotoAsset]
    if let remainingSlots {
      toIndex = Array(newAssets.prefix(remainingSlots))
    } else {
      toIndex = newAssets
    }

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

    let finalCount = existingCount + indexed
    progress = IndexingProgress(total: total, completed: total, currentAssetID: nil)
    state = !isPro && finalCount >= Self.freeIndexLimit
      ? .freeLimitReached(finalCount)
      : .completed(finalCount)
  }

  func rebuildIndex(modelContext: ModelContext, isPro: Bool) async {
    deleteIndex(modelContext: modelContext)
    await Task.yield()
    await indexScreenshots(modelContext: modelContext, isPro: isPro)
  }

  func reindex(record: ScreenshotRecord, modelContext: ModelContext) async throws {
    guard let asset = photoService.fetchScreenshot(localIdentifier: record.assetID) else {
      let error = IndexingError.assetUnavailable
      state = .failed(error)
      throw error
    }

    progress = IndexingProgress(total: 1, completed: 0, currentAssetID: asset.localIdentifier)
    state = .indexing(progress)

    do {
      let updatedRecord = try await buildRecord(for: asset)
      record.creationDate = updatedRecord.creationDate
      record.ocrText = updatedRecord.ocrText
      record.tags = updatedRecord.tags
      record.width = updatedRecord.width
      record.height = updatedRecord.height
      record.thumbnailData = updatedRecord.thumbnailData
      record.indexedAt = Date()
      try modelContext.save()
      progress = IndexingProgress(total: 1, completed: 1, currentAssetID: nil)
      state = .completed(fetchExistingIDs(modelContext: modelContext).count)
    } catch {
      state = .failed(error)
      throw error
    }
  }

  func deleteIndex(modelContext: ModelContext) {
    let descriptor = FetchDescriptor<ScreenshotRecord>()
    let records = (try? modelContext.fetch(descriptor)) ?? []
    for record in records {
      modelContext.delete(record)
    }
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

    let tagResult = taggingService.extractTags(
      from: ocrResult.text,
      width: asset.pixelWidth,
      height: asset.pixelHeight
    )
    let maxDimension: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 1600 : 800
    let thumbnailData = await makeThumbnail(from: imageData, maxDimension: maxDimension)

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

  private nonisolated func makeThumbnail(from data: Data, maxDimension: CGFloat) async -> Data? {
    await Task.detached(priority: .utility) {
      guard
        let image = UIImage(data: data),
        let thumb = image.preparingThumbnail(of: CGSize(width: maxDimension, height: maxDimension))
      else {
        return nil
      }
      return thumb.jpegData(compressionQuality: 0.85)
    }.value
  }
}

enum IndexingError: LocalizedError {
  case assetUnavailable

  var errorDescription: String? {
    switch self {
    case .assetUnavailable:
      "This screenshot is no longer available in Photos."
    }
  }
}
