import SwiftData
import SwiftUI

private enum HomeTab: Hashable {
  case library
  case search
  case settings
}

struct HomeView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(PurchaseManager.self) private var purchaseManager
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Query(sort: \ScreenshotRecord.creationDate, order: .reverse)
  private var records: [ScreenshotRecord]

  @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
  @AppStorage("gridZoomLevel") private var zoomLevelRaw = GridZoomLevel.comfortable.rawValue
  @State private var viewModel = HomeViewModel()
  @State private var showOnboarding = false
  @State private var selectedTab: HomeTab = .search
  @State private var libraryPath = NavigationPath()
  @State private var searchPath = NavigationPath()
  @State private var showIndexingToast = false
  @State private var indexingToastCount = 0
  @State private var indexingAuditMessage: String?

  private var zoomLevel: GridZoomLevel {
    GridZoomLevel(rawValue: zoomLevelRaw) ?? .comfortable
  }

  private var hidesTabBarDuringDetailNavigation: Bool {
    horizontalSizeClass == .compact
  }

  @ToolbarContentBuilder
  private func gridSizeToolbar() -> some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Menu {
        Picker("Grid Size", selection: $zoomLevelRaw) {
          Label("4 Columns", systemImage: "square.grid.2x2").tag(GridZoomLevel.fine.rawValue)
          Label("3 Columns", systemImage: "square.grid.2x2").tag(GridZoomLevel.comfortable.rawValue)
          Label("2 Columns", systemImage: "rectangle.grid.1x2").tag(GridZoomLevel.large.rawValue)
        }
      } label: {
        Image(systemName: "square.grid.3x2")
      }
    }
  }

  @ToolbarContentBuilder
  private func libraryToolbar() -> some ToolbarContent {
    gridSizeToolbar()

    if #available(iOS 26.0, *) {
      ToolbarSpacer(.fixed, placement: .topBarTrailing)
    }

    ToolbarItem(placement: .primaryAction) {
      if viewModel.isSelectionMode {
        Button {
          viewModel.exitSelectionMode()
        } label: {
          Label("Cancel", systemImage: "xmark").labelStyle(.titleAndIcon)
        }
      } else {
        Button("Select") { viewModel.enterSelectionMode() }
      }
    }
  }

  var body: some View {
    TabView(selection: $selectedTab) {
      Tab("SnapFound", systemImage: "sparkle.magnifyingglass", value: .search) {
        NavigationStack(path: $searchPath) {
          SearchTabView(records: records, viewModel: viewModel)
            .navigationDestination(for: ScreenshotRecord.self) { record in
              DetailView(
                record: record, allRecords: records,
                onPageChanged: {
                  viewModel.lastViewedAssetID = $0
                  viewModel.addRecentlyOpened($0)
                }
              )
            }
        }
        .toolbar(
          searchPath.isEmpty || !hidesTabBarDuringDetailNavigation ? .visible : .hidden,
          for: .tabBar
        )
        .animation(.snappy(duration: 0.25), value: searchPath.isEmpty)
      }

      Tab("Screenshots", systemImage: "photo.on.rectangle.angled", value: .library) {
        NavigationStack(path: $libraryPath) {
          HomeLibraryTabView(
            records: records,
            viewModel: viewModel,
            zoomLevel: zoomLevel,
            zoomLevelRaw: $zoomLevelRaw,
            openSettings: { selectedTab = .settings }
          )
          .navigationDestination(for: ScreenshotRecord.self) { record in
            DetailView(
              record: record, allRecords: records,
              onPageChanged: {
                viewModel.lastViewedAssetID = $0
                viewModel.addRecentlyOpened($0)
              }
            )
          }
          .toolbar { libraryToolbar() }
          .animation(.snappy(duration: 0.2), value: viewModel.isSelectionMode)
        }
        .toolbar(
          viewModel.isSelectionMode || (hidesTabBarDuringDetailNavigation && !libraryPath.isEmpty)
            ? .hidden : .visible,
          for: .tabBar
        )
        .animation(.snappy(duration: 0.25), value: viewModel.isSelectionMode)
        .animation(.snappy(duration: 0.25), value: libraryPath.isEmpty)
      }

      Tab("Settings", systemImage: "gear", value: .settings) {
        NavigationStack { SettingsView() }
      }
    }
    .onChange(of: selectedTab) { Haptics.selection() }
    .onChange(of: viewModel.searchText) { viewModel.search(in: records) }
    .onChange(of: viewModel.indexingState) { old, new in
      if case .completed(let count) = new, case .indexing = old {
        indexingToastCount = viewModel.indexingRunSummary?.indexedCount ?? count
        withAnimation(.spring(duration: 0.4)) { showIndexingToast = true }
        Haptics.notification(.success)
        if let summary = viewModel.indexingRunSummary, summary.hasSkips {
          indexingAuditMessage = indexingAuditDescription(for: summary)
        }
        Task {
          try? await Task.sleep(for: .seconds(3))
          withAnimation(.spring(duration: 0.4)) { showIndexingToast = false }
        }
      }
    }
    .overlay(alignment: .bottom) {
      if showIndexingToast {
        IndexingToastView(count: indexingToastCount)
          .padding(.bottom, 90)
          .transition(.move(edge: .bottom).combined(with: .opacity))
      }
    }
    .animation(.spring(duration: 0.4), value: showIndexingToast)
    .sheet(isPresented: $viewModel.showPaywall) {
      PaywallView {
        viewModel.startIndexing(modelContext: modelContext, isPro: purchaseManager.isPro)
      }
    }
    .sheet(isPresented: $viewModel.showShareSheet, onDismiss: viewModel.clearShareState) {
      ActivityShareSheet(items: viewModel.shareItems).presentationDetents([.medium, .large])
    }
    .alert("Couldn't Prepare Share", isPresented: .constant(viewModel.shareErrorMessage != nil)) {
      Button("OK", role: .cancel) { viewModel.shareErrorMessage = nil }
    } message: {
      Text(viewModel.shareErrorMessage ?? "The selected screenshots could not be loaded.")
    }
    .alert("Some Screenshots Weren't Indexed", isPresented: .constant(indexingAuditMessage != nil))
    {
      Button("OK", role: .cancel) { indexingAuditMessage = nil }
    } message: {
      Text(indexingAuditMessage ?? "")
    }
    .fullScreenCover(isPresented: $showOnboarding) {
      OnboardingView {
        showOnboarding = false
        Task { @MainActor in
          hasSeenOnboarding = true
          guard records.isEmpty else { return }
          viewModel.startIndexing(modelContext: modelContext, isPro: purchaseManager.isPro)
        }
      }
    }
    .onAppear {
      if !hasSeenOnboarding {
        showOnboarding = true
      } else {
        viewModel.onAppear(
          modelContext: modelContext, records: records, isPro: purchaseManager.isPro)
      }
    }
  }
}

private func indexingAuditDescription(for summary: IndexingRunSummary) -> String {
  var parts: [String] = []

  if summary.skippedCloudCount > 0 {
    parts.append(
      "\(summary.skippedCloudCount) screenshot\(summary.skippedCloudCount == 1 ? "" : "s") couldn't be downloaded from iCloud."
    )
  }

  if summary.skippedOtherCount > 0 {
    parts.append(
      "\(summary.skippedOtherCount) screenshot\(summary.skippedOtherCount == 1 ? "" : "s") couldn't be indexed for another Photos error."
    )
  }

  parts.append("Reconnect to the internet and run indexing again to retry skipped screenshots.")
  return parts.joined(separator: " ")
}

private struct IndexingToastView: View {
  let count: Int

  var body: some View {
    Label("\(count) screenshots indexed", systemImage: "checkmark.circle.fill")
      .font(.subheadline.weight(.medium))
      .foregroundStyle(.white)
      .padding(.horizontal, 18)
      .padding(.vertical, 12)
      .background(.green, in: Capsule())
      .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
  }
}

private struct ActivityShareSheet: UIViewControllerRepresentable {
  let items: [Any]

  func makeUIViewController(context: Context) -> UIActivityViewController {
    UIActivityViewController(activityItems: items, applicationActivities: nil)
  }

  func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview("Empty") {
  HomeView()
    .environment(PurchaseManager())
    .modelContainer(for: ScreenshotRecord.self, inMemory: true)
}
