import SwiftData
import SwiftUI

struct SettingsView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(PurchaseManager.self) private var purchaseManager
  @Environment(\.dismiss) private var dismiss
  @Environment(\.openURL) var openURL
  @Query private var records: [ScreenshotRecord]

  @State private var viewModel = SettingsViewModel()
  @State private var showPaywall = false
  @State private var showIndexingInProgressAlert = false

  var body: some View {
    NavigationStack {
      List {
        privacySection
        indexSection
        proSection
        aboutSection
      }
      .navigationTitle("Settings")
      .alert("Delete all indexed data?", isPresented: $viewModel.showDeleteConfirmation) {
        Button("Delete Index", role: .destructive) {
          viewModel.deleteIndex(modelContext: modelContext)
        }
        Button("Cancel", role: .cancel) {}
      } message: {
        Text("This removes all OCR text and tags. Your photos are not affected.")
      }
      .alert("Re-index screenshots?", isPresented: $viewModel.showRebuildConfirmation) {
        Button("Re-index", role: .destructive) {
          viewModel.rebuildIndex(modelContext: modelContext, isPro: purchaseManager.isPro)
          dismiss()
        }
        Button("Cancel", role: .cancel) {}
      } message: {
        Text(
          "All existing index data will be deleted and rebuilt from scratch. This may take a few minutes."
        )
      }
      .alert("Indexing Already Running", isPresented: $showIndexingInProgressAlert) {
        Button("OK", role: .cancel) {}
      } message: {
        Text("SnapFound is already indexing your screenshots. Please wait for it to finish.")
      }
      .sheet(isPresented: $showPaywall) {
        PaywallView()
      }
    }
  }

  // MARK: - Privacy Section

  private var privacySection: some View {
    Section {
      Label {
        VStack(alignment: .leading, spacing: 4) {
          Text("Privacy First")
            .font(.headline)
          Text(
            "All OCR, tagging, indexing, and search processing happens entirely on this device."
          )
          .font(.caption)
          .foregroundStyle(.secondary)
        }
      } icon: {
        Image(systemName: "lock.shield.fill")
          .foregroundStyle(.green)
      }

      PrivacyPromiseRow(icon: "icloud.slash", text: "No cloud processing")
      PrivacyPromiseRow(icon: "hand.raised.slash", text: "No tracking")
      PrivacyPromiseRow(icon: "person.crop.circle.badge.xmark", text: "No account required")
      PrivacyPromiseRow(icon: "iphone", text: "Your screenshots stay on your iPhone")
      PrivacyPromiseRow(icon: "trash", text: "You can delete the local index anytime")
    }
  }

  // MARK: - Index Section

  private var indexSection: some View {
    Section("Index") {
      LabeledContent("Screenshots indexed", value: "\(records.count)")
      LabeledContent("Free limit", value: "\(IndexingService.freeIndexLimit) screenshots")

      Button {
        if case .indexing = viewModel.indexingState {
          Haptics.notification(.warning)
          showIndexingInProgressAlert = true
        } else if !purchaseManager.isPro && records.count >= IndexingService.freeIndexLimit {
          Haptics.impact(.light)
          showPaywall = true
        } else {
          Haptics.impact(.medium)
          viewModel.indexNew(modelContext: modelContext, isPro: purchaseManager.isPro)
          dismiss()
        }
      } label: {
        Label("Index New Screenshots", systemImage: "arrow.clockwise")
      }

      Button {
        Haptics.selection()
        viewModel.openAppSettings()
      } label: {
        Label("Manage Photos Permission", systemImage: "photo.badge.shield.exclamationmark")
      }

      Button {
        Haptics.impact(.medium)
        viewModel.showRebuildConfirmation = true
      } label: {
        Label("Rebuild Full Index", systemImage: "arrow.2.circlepath")
          .foregroundStyle(.orange)
      }

      Button(role: .destructive) {
        Haptics.notification(.warning)
        viewModel.showDeleteConfirmation = true
      } label: {
        Label("Delete Index", systemImage: "trash")
          .foregroundStyle(.red)
      }
    }
  }

  // MARK: - Pro Section

  private var proSection: some View {
    Section("Pro") {
      if purchaseManager.isPro {
        Label("SnapFound Pro - Active", systemImage: "checkmark.seal.fill")
          .foregroundStyle(.green)
      } else {
        Button {
          Haptics.impact(.light)
          showPaywall = true
        } label: {
          Label("Unlock Unlimited Indexing", systemImage: "sparkles")
        }
      }

      Button {
        Haptics.selection()
        Task { await purchaseManager.restorePurchases() }
      } label: {
        Label("Restore Purchase", systemImage: "arrow.clockwise.circle")
          .foregroundStyle(.secondary)
      }
    }
  }

  // MARK: - About Section
  private var aboutSection: some View {
    Section("About") {
      LabeledContent("Version", value: Bundle.main.appVersionString)
      Button {
        openURL(URL(string: "https://snapfound.app/privacy")!, prefersInApp: true)
      } label: {
        Label("Privacy Policy", systemImage: "hand.raised")
      }
    }
  }
}

private struct PrivacyPromiseRow: View {
  let icon: String
  let text: String

  var body: some View {
    Label(text, systemImage: icon)
      .font(.subheadline)
      .foregroundStyle(.primary)
  }
}

// MARK: - Bundle helpers

extension Bundle {
  fileprivate var appVersionString: String {
    let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    let build = infoDictionary?["CFBundleVersion"] as? String ?? "1"
    return "\(version) (\(build))"
  }
}

#Preview {
  SettingsView()
    .environment(PurchaseManager())
    .modelContainer(for: ScreenshotRecord.self, inMemory: true)
}
