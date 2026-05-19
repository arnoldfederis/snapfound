import SwiftData
import SwiftUI

struct SettingsView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(PurchaseManager.self) private var purchaseManager
  @Environment(\.dismiss) private var dismiss
  @Query private var records: [ScreenshotRecord]

  @State private var viewModel = SettingsViewModel()
  @State private var showPaywall = false

  var body: some View {
    NavigationStack {
      List {
        privacySection
        indexSection
        proSection
        aboutSection
      }
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Done") { dismiss() }
        }
      }
      .confirmationDialog(
        "Delete all indexed data?",
        isPresented: $viewModel.showDeleteConfirmation,
        titleVisibility: .visible
      ) {
        Button("Delete Index", role: .destructive) {
          viewModel.deleteIndex(modelContext: modelContext)
        }
        Button("Cancel", role: .cancel) {}
      } message: {
        Text("This removes all OCR text and tags. Your photos are not affected.")
      }
      .confirmationDialog(
        "Rebuild full index?",
        isPresented: $viewModel.showRebuildConfirmation,
        titleVisibility: .visible
      ) {
        Button("Rebuild", role: .destructive) {
          viewModel.rebuildIndex(modelContext: modelContext, isPro: purchaseManager.isPro)
          dismiss()
        }
        Button("Cancel", role: .cancel) {}
      } message: {
        Text(
          "All existing index data will be deleted and rebuilt from scratch. This may take a few minutes."
        )
      }
      .sheet(isPresented: $showPaywall) {
        PaywallView()
      }
    }
  }

  // MARK: - Privacy Section

  private var privacySection: some View {
    Section {
      HStack(alignment: .top, spacing: 12) {
        Image(systemName: "lock.shield.fill")
          .font(.title2)
          .foregroundStyle(.green)
          .frame(width: 32)

        VStack(alignment: .leading, spacing: 4) {
          Text("Privacy First")
            .font(.headline)
          Text(
            "All OCR and search processing happens entirely on this device. No data is ever sent to any server. No account required. No analytics."
          )
          .font(.caption)
          .foregroundStyle(.secondary)
        }
      }
      .padding(.vertical, 4)
    }
  }

  // MARK: - Index Section

  private var indexSection: some View {
    Section("Index") {
      LabeledContent("Screenshots indexed", value: "\(records.count)")
      LabeledContent("Free limit", value: "\(IndexingService.freeIndexLimit) screenshots")

      Button {
        viewModel.indexNew(modelContext: modelContext, isPro: purchaseManager.isPro)
        dismiss()
      } label: {
        Label("Index New Screenshots", systemImage: "arrow.clockwise")
      }

      Button {
        viewModel.showRebuildConfirmation = true
      } label: {
        Label("Rebuild Full Index", systemImage: "arrow.2.circlepath")
          .foregroundStyle(.orange)
      }

      Button(role: .destructive) {
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
        Label("SnapFound Pro — Active", systemImage: "checkmark.seal.fill")
          .foregroundStyle(.green)
      } else {
        Button {
          showPaywall = true
        } label: {
          Label("Unlock Unlimited Indexing", systemImage: "sparkles")
        }

        Button {
          Task { await purchaseManager.restorePurchases() }
        } label: {
          Label("Restore Purchase", systemImage: "arrow.clockwise.circle")
            .foregroundStyle(.secondary)
        }
      }
    }
  }

  // MARK: - About Section

  private var aboutSection: some View {
    Section("About") {
      LabeledContent("Version", value: Bundle.main.appVersionString)
      Link(destination: URL(string: "https://snapfound.app/privacy")!) {
        Label("Privacy Policy", systemImage: "hand.raised")
      }
    }
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
