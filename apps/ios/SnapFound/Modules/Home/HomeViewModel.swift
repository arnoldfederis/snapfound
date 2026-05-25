import Foundation
import Photos
import SwiftData
internal import UIKit

@MainActor
@Observable
final class HomeViewModel {
  var searchText = ""
  var showPaywall = false
  var showSettings = false
  var lastViewedAssetID: String?

  // Selection mode
  var isSelectionMode = false
  var selectedIDs: Set<String> = []
  var showDeleteSelected = false
  var isPreparingShare = false
  var showShareSheet = false
  var shareItems: [UIImage] = []
  var shareErrorMessage: String?

  private(set) var searchService = SearchService()
  private let indexingService = IndexingService.shared

  var indexingState: IndexingState {
    indexingService.state
  }

  var indexingProgress: IndexingProgress {
    indexingService.progress
  }

  var isSearchActive: Bool {
    !searchText.trimmingCharacters(in: .whitespaces).isEmpty
  }

  var searchResults: [SearchResult] {
    searchService.results
  }

  var isLimitedPhotoAccess: Bool {
    PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited
  }

  func onAppear(
    modelContext: ModelContext,
    records: [ScreenshotRecord],
    isPro: Bool
  ) {
    guard case .idle = indexingService.state else { return }
    if records.isEmpty {
      startIndexing(modelContext: modelContext, isPro: isPro)
    }
  }

  func startIndexing(modelContext: ModelContext, isPro: Bool) {
    Task {
      await indexingService.requestPermissionAndIndex(
        modelContext: modelContext,
        isPro: isPro
      )
    }
  }

  func search(in records: [ScreenshotRecord]) {
    if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
      searchService.clear()
    } else {
      searchService.search(query: searchText, in: records)
    }
  }

  func isAtFreeLimit(recordsCount: Int, isPro: Bool) -> Bool {
    !isPro && recordsCount >= IndexingService.freeIndexLimit
  }

  // MARK: - Selection

  func enterSelectionMode() {
    isSelectionMode = true
    Haptics.impact(.medium)
  }

  func exitSelectionMode() {
    isSelectionMode = false
    selectedIDs.removeAll()
  }

  func toggleSelection(_ id: String) {
    if selectedIDs.contains(id) {
      selectedIDs.remove(id)
    } else {
      selectedIDs.insert(id)
      Haptics.selection()
    }
  }

  func deleteSelected(modelContext: ModelContext, records: [ScreenshotRecord]) {
    let toDelete = records.filter { selectedIDs.contains($0.assetID) }
    for record in toDelete { modelContext.delete(record) }
    try? modelContext.save()
    exitSelectionMode()
    Haptics.notification(.success)
  }
  
  func shareSelected(records: [ScreenshotRecord]) async {
    guard !isPreparingShare else { return }

    let selectedRecords = records.filter { selectedIDs.contains($0.assetID) }
    guard !selectedRecords.isEmpty else { return }

    isPreparingShare = true
    shareErrorMessage = nil
    defer { isPreparingShare = false }

    do {
      let images = try await loadSelectedImages(from: selectedRecords)
      guard !images.isEmpty else {
        throw PhotoLibraryError.imageLoadFailed
      }

      shareItems = images
      showShareSheet = true
      Haptics.impact(.light)
    } catch {
      shareErrorMessage = error.localizedDescription
      Haptics.notification(.error)
    }
  }

  private func loadSelectedImages(from records: [ScreenshotRecord]) async throws -> [UIImage] {
    let orderedData = try await withThrowingTaskGroup(of: (Int, Data).self) { group in
      for (index, record) in records.enumerated() {
        let assetID = record.assetID
        group.addTask {
          let data = try await PhotoLibraryService.shared.loadFullImageData(for: assetID)
          return (index, data)
        }
      }

      var results = Array<Data?>(repeating: nil, count: records.count)
      for try await (index, data) in group {
        results[index] = data
      }
      return results
    }

    let images = orderedData.compactMap { data -> UIImage? in
      guard let data else { return nil }
      return UIImage(data: data)
    }

    guard images.count == records.count else {
      throw PhotoLibraryError.imageLoadFailed
    }

    return images
  }

  func clearShareState() {
    shareItems = []
    shareErrorMessage = nil
  }
}
