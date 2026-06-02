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
  @State private var rebuildIconAngle: Double = 0
  @State private var showUpToDateToast = false

  var body: some View {
    NavigationStack {
      List {
        privacySection
        indexSection
        proSection
        aboutSection
      }
      .animation(.spring(response: 0.35), value: records.isEmpty)
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
        PaywallView {
          viewModel.indexNew(modelContext: modelContext, isPro: purchaseManager.isPro)
          dismiss()
        }
      }
      .onChange(of: viewModel.indexingState) { old, new in
        switch new {
        case .indexing:
          dismiss()
        case .completed:
          if case .requestingPermission = old {
            Haptics.notification(.success)
            withAnimation(.spring(duration: 0.4)) { showUpToDateToast = true }
            Task {
              try? await Task.sleep(for: .seconds(3))
              withAnimation(.spring(duration: 0.4)) { showUpToDateToast = false }
            }
          }
        default:
          break
        }
      }
      .overlay(alignment: .bottom) {
        if showUpToDateToast {
          Label("Already up to date", systemImage: "checkmark.circle.fill")
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(.green, in: Capsule())
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
            .padding(.bottom, 16)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
      }
      .animation(.spring(duration: 0.4), value: showUpToDateToast)
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

  // MARK: - Status Banners Section

  @ViewBuilder
  private var statusBannersSection: some View {
    let isIndexing: Bool = {
      if case .indexing = viewModel.indexingState { return true }
      return false
    }()
    let hasBanners = isIndexing || viewModel.isPhotoAccessDenied || viewModel.isLimitedPhotoAccess

    if hasBanners {
      VStack(spacing: 8) {
        if case .indexing(let prog) = viewModel.indexingState {
          IndexingProgressBanner(progress: prog)
        }
        if viewModel.isPhotoAccessDenied {
          PermissionDeniedBanner(showAction: false)
        }
        if viewModel.isLimitedPhotoAccess {
          LimitedAccessBanner(showAction: false)
        }
      }
      .frame(maxWidth: .infinity)
      .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
      .listRowSeparator(.hidden)
    }
  }

  // MARK: - Index Section

  private var indexSection: some View {
    let isIndexing: Bool = {
      if case .indexing = viewModel.indexingState { return true }
      return false
    }()

    return Section("Index") {
      statusBannersSection

      if !isIndexing {
        LabeledContent("Screenshots indexed", value: "\(records.count)")
      }

      if !purchaseManager.isPro {
        LabeledContent("Free limit", value: "\(IndexingService.freeIndexLimit) screenshots")
      }

      Button {
        if isIndexing {
          Haptics.notification(.warning)
          showIndexingInProgressAlert = true
        } else if !purchaseManager.isPro && records.count >= IndexingService.freeIndexLimit {
          Haptics.impact(.light)
          showPaywall = true
        } else {
          Haptics.impact(.medium)
          viewModel.indexNew(modelContext: modelContext, isPro: purchaseManager.isPro)
        }
      } label: {
        Label("Index New Screenshots", systemImage: "arrow.clockwise")
      }
      .tint(.accentColor)

      Button {
        Haptics.selection()
        viewModel.openAppSettings()
      } label: {
        Label("Manage Photos Permission", systemImage: "photo.badge.shield.exclamationmark")
      }
      .tint(.accentColor)

      if !records.isEmpty && !isIndexing {
        Button {
          Haptics.impact(.medium)
          withAnimation(.easeInOut(duration: 0.45)) {
            rebuildIconAngle += 360
          }
          viewModel.showRebuildConfirmation = true
        } label: {
          Label {
            Text("Rebuild Full Index")
          } icon: {
            Image(systemName: "arrow.2.circlepath")
              .rotationEffect(.degrees(rebuildIconAngle))
          }
        }
        .tint(.accentColor)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))

        Button(role: .destructive) {
          Haptics.notification(.warning)
          viewModel.showDeleteConfirmation = true
        } label: {
          Label("Delete Index", systemImage: "trash")
            .foregroundStyle(.red)
        }
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
        .tint(.accentColor)
      }

      Button {
        Haptics.selection()
        Task { await purchaseManager.restorePurchases() }
      } label: {
        Label("Restore Purchase", systemImage: "arrow.clockwise.circle")
      }
      .tint(.accentColor)
    }
  }

  // MARK: - About Section
  private var aboutSection: some View {
    Section("About") {
      LabeledContent("Version", value: Bundle.main.appVersionString)
      Button {
        if #available(iOS 26.0, *) {
          openURL(URL(string: "https://snapfound.app/privacy")!, prefersInApp: true)
        } else {
          // Fallback on earlier versions
          UIApplication.shared.open(URL(string: "https://snapfound.app/privacy")!)
        }
      } label: {
        Label("Privacy Policy", systemImage: "hand.raised")
      }
      .tint(.accentColor)
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
