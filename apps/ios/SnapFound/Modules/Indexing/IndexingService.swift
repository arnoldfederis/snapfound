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
  private(set) var lastRunSummary: IndexingRunSummary?

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
    lastRunSummary = nil
    let existingIDs = fetchExistingIDs(modelContext: modelContext)
    let existingCount = existingIDs.count

    let remainingSlots = isPro ? nil : max(0, Self.freeIndexLimit - existingCount)
    if let slots = remainingSlots, slots == 0 {
      state = .freeLimitReached(existingCount)
      return
    }

    let assets = photoService.fetchScreenshots()
    let newAssets = assets.filter { !existingIDs.contains($0.localIdentifier) }

    guard !newAssets.isEmpty else {
      state = .completed(existingCount)
      return
    }

    let targetSuccessfulIndexes = remainingSlots ?? newAssets.count
    let progressTotal = isPro ? newAssets.count : min(targetSuccessfulIndexes, newAssets.count)
    progress = IndexingProgress(total: progressTotal, completed: 0, currentAssetID: nil)
    state = .indexing(progress)

    var indexed = 0
    var skippedCloud = 0
    var skippedOther = 0
    for asset in newAssets {
      if indexed >= targetSuccessfulIndexes {
        break
      }

      progress = IndexingProgress(
        total: progressTotal,
        completed: indexed,
        currentAssetID: asset.localIdentifier
      )
      state = .indexing(progress)

      do {
        let record = try await buildRecord(for: asset)
        modelContext.insert(record)
        try? modelContext.save()
        indexed += 1
      } catch {
        if case PhotoLibraryError.cloudAssetUnavailableOffline = error {
          skippedCloud += 1
        } else {
          skippedOther += 1
        }
        #if DEBUG
          print("[IndexingService] skip \(asset.localIdentifier): \(error)")
        #endif
      }
    }

    let finalCount = existingCount + indexed
    lastRunSummary = IndexingRunSummary(
      indexedCount: indexed,
      skippedCloudCount: skippedCloud,
      skippedOtherCount: skippedOther,
      totalIndexedCount: finalCount
    )
    progress = IndexingProgress(
      total: progressTotal,
      completed: min(indexed, progressTotal),
      currentAssetID: nil
    )
    state =
      !isPro && finalCount >= Self.freeIndexLimit
      ? .freeLimitReached(finalCount)
      : .completed(finalCount)
  }

  func rebuildIndex(modelContext: ModelContext, isPro: Bool) async {
    deleteIndex(modelContext: modelContext)
    await Task.yield()
    await indexScreenshots(modelContext: modelContext, isPro: isPro)
  }

  func reindex(record: ScreenshotRecord, modelContext: ModelContext) async throws {
    lastRunSummary = nil
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
      lastRunSummary = IndexingRunSummary(
        indexedCount: 1,
        skippedCloudCount: 0,
        skippedOtherCount: 0,
        totalIndexedCount: fetchExistingIDs(modelContext: modelContext).count
      )
      progress = IndexingProgress(total: 1, completed: 1, currentAssetID: nil)
      state = .completed(fetchExistingIDs(modelContext: modelContext).count)
    } catch {
      if case PhotoLibraryError.cloudAssetUnavailableOffline = error {
        lastRunSummary = IndexingRunSummary(
          indexedCount: 0,
          skippedCloudCount: 1,
          skippedOtherCount: 0,
          totalIndexedCount: fetchExistingIDs(modelContext: modelContext).count
        )
      }
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
    lastRunSummary = nil
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
    // UIImage and preparingThumbnail are @MainActor in newer SDKs; calling them
    // from Task.detached triggers unsafeForcedSync. Use ImageIO/CoreGraphics
    // APIs instead — they are fully thread-safe and have no actor restriction.
    await Task.detached(priority: .utility) {
      let options: [CFString: Any] = [
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceThumbnailMaxPixelSize: maxDimension,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceShouldCacheImmediately: false,
      ]
      guard
        let source = CGImageSourceCreateWithData(data as CFData, nil),
        let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
      else { return nil }

      let dest = NSMutableData()
      guard
        let destination = CGImageDestinationCreateWithData(dest, "public.jpeg" as CFString, 1, nil)
      else { return nil }
      CGImageDestinationAddImage(
        destination, thumbnail,
        [kCGImageDestinationLossyCompressionQuality: 0.85] as CFDictionary
      )
      return CGImageDestinationFinalize(destination) ? dest as Data : nil
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
