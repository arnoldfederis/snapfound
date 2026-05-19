import Foundation
import SwiftData

@MainActor
@Observable
final class SettingsViewModel {
  var showDeleteConfirmation = false
  var showRebuildConfirmation = false

  private let indexingService = IndexingService.shared

  func deleteIndex(modelContext: ModelContext) {
    indexingService.deleteIndex(modelContext: modelContext)
  }

  func indexNew(modelContext: ModelContext, isPro: Bool) {
    Task {
      await indexingService.requestPermissionAndIndex(
        modelContext: modelContext,
        isPro: isPro
      )
    }
  }

  func rebuildIndex(modelContext: ModelContext, isPro: Bool) {
    Task {
      await indexingService.rebuildIndex(modelContext: modelContext, isPro: isPro)
    }
  }
}
