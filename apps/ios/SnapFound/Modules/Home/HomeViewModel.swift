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

  // Selection mode
  var isSelectionMode = false
  var selectedIDs: Set<String> = []
  var showDeleteSelected = false

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
}
