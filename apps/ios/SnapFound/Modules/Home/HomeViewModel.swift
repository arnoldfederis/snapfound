import Foundation
import Photos
import SwiftData
internal import UIKit

struct RecentlyOpenedEntry: Codable {
  let assetID: String
  let openedAt: Date
}

enum RecentlyOpenedStore {
  static let key = "recentlyOpenedV2"

  static func load() -> [RecentlyOpenedEntry] {
    guard let data = UserDefaults.standard.data(forKey: key),
      let entries = try? JSONDecoder().decode([RecentlyOpenedEntry].self, from: data)
    else { return [] }
    return entries
  }

  static func save(_ entries: [RecentlyOpenedEntry]) {
    if let data = try? JSONEncoder().encode(entries) {
      UserDefaults.standard.set(data, forKey: key)
    }
  }

  static func remove(assetIDs: Set<String>) {
    let remainingEntries = load().filter { !assetIDs.contains($0.assetID) }
    save(remainingEntries)
  }

  static func clear() {
    UserDefaults.standard.removeObject(forKey: key)
  }
}

@MainActor
@Observable
final class HomeViewModel {
  var searchText = ""
  var showPaywall = false
  var lastViewedAssetID: String?

  // Selection mode
  var isSelectionMode = false
  var selectedIDs: Set<String> = []
  var isPreparingShare = false
  var showShareSheet = false
  var shareItems: [UIImage] = []
  var shareErrorMessage: String?

  private(set) var recentlyOpened: [RecentlyOpenedEntry] = {
    RecentlyOpenedStore.load()
  }()

  private(set) var searchService = SearchService()
  private let indexingService = IndexingService.shared

  var indexingState: IndexingState {
    indexingService.state
  }

  var indexingProgress: IndexingProgress {
    indexingService.progress
  }

  var indexingRunSummary: IndexingRunSummary? {
    indexingService.lastRunSummary
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
    let deletedIDs = selectedIDs
    let toDelete = records.filter { deletedIDs.contains($0.assetID) }
    for record in toDelete { modelContext.delete(record) }
    try? modelContext.save()
    RecentlyOpenedStore.remove(assetIDs: deletedIDs)
    recentlyOpened.removeAll { deletedIDs.contains($0.assetID) }
    if isSearchActive {
      let remainingRecords = records.filter { !deletedIDs.contains($0.assetID) }
      search(in: remainingRecords)
    }
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
    var images: [UIImage] = []
    images.reserveCapacity(records.count)

    for record in records {
      let data = try await PhotoLibraryService.shared.loadFullImageData(for: record.assetID)
      guard let image = UIImage(data: data) else {
        throw PhotoLibraryError.imageLoadFailed
      }
      images.append(image)
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

  // MARK: - Recently Opened

  func addRecentlyOpened(_ assetID: String) {
    var entries = recentlyOpened.filter { $0.assetID != assetID }
    entries.insert(RecentlyOpenedEntry(assetID: assetID, openedAt: Date()), at: 0)
    recentlyOpened = Array(entries.prefix(20))
    RecentlyOpenedStore.save(recentlyOpened)
  }

  func clearRecentlyOpened() {
    recentlyOpened = []
    RecentlyOpenedStore.clear()
    Haptics.notification(.success)
  }
}
