import SwiftData
import SwiftUI

struct HomeView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(PurchaseManager.self) private var purchaseManager
  @Query(sort: \ScreenshotRecord.creationDate, order: .reverse)
  private var records: [ScreenshotRecord]

  @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
  @AppStorage("gridZoomLevel") private var zoomLevelRaw = GridZoomLevel.comfortable.rawValue
  @State private var viewModel = HomeViewModel()
  @State private var showOnboarding = false
  @State private var isSearchPresented = false

  private var zoomLevel: GridZoomLevel {
    GridZoomLevel(rawValue: zoomLevelRaw) ?? .comfortable
  }

  var body: some View {
    NavigationStack {
      HomeBodyView(
        records: records,
        viewModel: viewModel,
        zoomLevel: zoomLevel,
        zoomLevelRaw: $zoomLevelRaw,
        isSearchPresented: $isSearchPresented
      )
      .navigationDestination(for: ScreenshotRecord.self) { record in
        DetailView(record: record, allRecords: records, onPageChanged: { assetID in
          viewModel.lastViewedAssetID = assetID
        })
      }
      .searchable(text: $viewModel.searchText, isPresented: $isSearchPresented, prompt: "Search screenshots…")
      .onChange(of: viewModel.searchText) {
        viewModel.search(in: records)
      }
      .toolbar {
        if viewModel.isSelectionMode {
          ToolbarItem(placement: .topBarLeading) {
            Button("Cancel") { viewModel.exitSelectionMode() }
          }
          ToolbarItem(placement: .topBarTrailing) {
            Button {
              viewModel.showDeleteSelected = true
              Haptics.notification(.warning)
            } label: {
              Label("Delete Selected", systemImage: "trash")
            }
            .disabled(viewModel.selectedIDs.isEmpty)
            .tint(.red)
            .confirmationDialog(
              "Delete \(viewModel.selectedIDs.count) Screenshots from Index?",
              isPresented: $viewModel.showDeleteSelected,
              titleVisibility: .visible
            ) {
              Button("Delete \(viewModel.selectedIDs.count)", role: .destructive) {
                viewModel.deleteSelected(modelContext: modelContext, records: records)
                viewModel.showDeleteSelected = false
              }

              Button("Cancel", role: .cancel) {
                viewModel.showDeleteSelected = false
              }
            } message: {
              Text(
                "All existing index data will be deleted and rebuilt from scratch. This may take a few minutes."
              )
            }
          }
        } else {
          ToolbarItemGroup(placement: .topBarTrailing) {
            Button {
              viewModel.showSettings = true
            } label: {
              Image(systemName: "gear")
            }
          }
        }
      }
      .sheet(isPresented: $viewModel.showSettings) {
        SettingsView()
      }
      .sheet(isPresented: $viewModel.showPaywall) {
        PaywallView()
      }
      .fullScreenCover(isPresented: $showOnboarding) {
        OnboardingView {
          hasSeenOnboarding = true
          showOnboarding = false
        }
      }
      .onAppear {
        if !hasSeenOnboarding { showOnboarding = true }
        viewModel.onAppear(
          modelContext: modelContext,
          records: records,
          isPro: purchaseManager.isPro
        )
      }
    }
  }

}

// MARK: - Body (needs its own type to access isSearching environment)

private struct HomeBodyView: View {
  let records: [ScreenshotRecord]
  let viewModel: HomeViewModel
  let zoomLevel: GridZoomLevel
  @Binding var zoomLevelRaw: Int
  @Binding var isSearchPresented: Bool

  @Environment(PurchaseManager.self) private var purchaseManager

  private let searchSuggestions = [
    "Receipts", "Wi-Fi password", "Flight", "Hotel booking",
    "Order confirmation", "Error message", "Verification code",
    "Tracking number", "Map", "Meeting notes",
  ]

  var body: some View {
    Group {
      if viewModel.isSearchActive {
        searchResultsView
      } else {
        mainGridView
      }
    }
    .navigationTitle(navigationTitle)
    .searchSuggestions {
      if viewModel.searchText.isEmpty {
        ForEach(searchSuggestions, id: \.self) { suggestion in
          Label(suggestion, systemImage: "magnifyingglass")
            .searchCompletion(suggestion)
        }
      }
    }
    .toolbar {
      ToolbarItemGroup(placement: .bottomBar) {
        Menu {
          Picker("Grid Size", selection: $zoomLevelRaw) {
            Label("5 Columns", systemImage: "square.grid.3x2").tag(GridZoomLevel.compact.rawValue)
            Label("4 Columns", systemImage: "square.grid.2x2").tag(GridZoomLevel.fine.rawValue)
            Label("3 Columns", systemImage: "square.grid.2x2").tag(GridZoomLevel.comfortable.rawValue)
            Label("2 Columns", systemImage: "rectangle.grid.1x2").tag(GridZoomLevel.large.rawValue)
          }
        } label: {
          Image(systemName: "square.grid.3x2")
        }
        Spacer()
        Button {
          isSearchPresented = true
        } label: {
          Image(systemName: "magnifyingglass")
        }
      }
    }
  }

  private var navigationTitle: String {
    if viewModel.isSelectionMode {
      return viewModel.selectedIDs.isEmpty
        ? "Select Screenshots"
        : "\(viewModel.selectedIDs.count) Selected"
    }
    if viewModel.isSearchActive {
      let c = viewModel.searchResults.count
      return "\(c) \(c == 1 ? "Result" : "Results")"
    }
    return "SnapFound"
  }

  // MARK: - Main Grid

  private var mainGridView: some View {
    ScrollViewReader { proxy in
      ScrollView {
        VStack(spacing: 16) {
          indexingStatusBanner
          limitedAccessBanner
          freeLimitBanner

          if records.isEmpty {
            noScreenshotsEmptyState
          } else if zoomLevel.isGrouped {
            groupedGridView
          } else {
            flatGrid(items: records.map { CellItem(record: $0, terms: []) })
          }
        }
        .padding(.horizontal, zoomLevel == .compact ? 6 : 16)
        .padding(.top, 8)
      }
      .onAppear {
        if let id = viewModel.lastViewedAssetID {
          proxy.scrollTo(id, anchor: .center)
        }
      }
    }
  }

  // MARK: - Grouped View (months / years)

  private var groupedGridView: some View {
    LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
      ForEach(groupedRecords, id: \.key) { group in
        Section {
          LazyVGrid(columns: gridColumns(for: .comfortable), spacing: 10) {
            ForEach(group.records, id: \.assetID) { record in
              cell(for: CellItem(record: record, terms: []))
                .id(record.assetID)
            }
          }
          .padding(.horizontal, 16)
          .padding(.bottom, 16)
        } header: {
          Text(group.key)
            .font(.headline)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial)
        }
      }
    }
  }

  private struct DateGroup {
    let key: String
    let records: [ScreenshotRecord]
  }

  private var groupedRecords: [DateGroup] {
    let cal = Calendar.current
    var result: [DateGroup] = []
    var keyToIndex: [String: Int] = [:]

    for record in records {
      let key: String
      if zoomLevel == .years {
        key = String(cal.component(.year, from: record.creationDate))
      } else {
        key = record.creationDate.formatted(.dateTime.month(.wide).year())
      }
      if let idx = keyToIndex[key] {
        result[idx] = DateGroup(key: key, records: result[idx].records + [record])
      } else {
        keyToIndex[key] = result.count
        result.append(DateGroup(key: key, records: [record]))
      }
    }
    return result
  }

  // MARK: - Flat Grid

  private func flatGrid(items: [CellItem]) -> some View {
    LazyVGrid(columns: gridColumns(for: zoomLevel), spacing: zoomLevel.spacing) {
      ForEach(items, id: \.record.assetID) { item in
        cell(for: item)
          .id(item.record.assetID)
      }
    }
  }

  private func gridColumns(for level: GridZoomLevel) -> [GridItem] {
    let count = level.columnCount ?? 3
    return Array(repeating: GridItem(.flexible(), spacing: level.spacing), count: count)
  }

  // MARK: - Cell

  @ViewBuilder
  private func cell(for item: CellItem) -> some View {
    let isSelected = viewModel.selectedIDs.contains(item.record.assetID)

    if viewModel.isSelectionMode {
      Button {
        viewModel.toggleSelection(item.record.assetID)
      } label: {
        ScreenshotGridCell(
          record: item.record,
          matchedTerms: item.terms,
          isSelected: isSelected
        )
      }
      .buttonStyle(.plain)
    } else {
      NavigationLink(value: item.record) {
        ScreenshotGridCell(
          record: item.record,
          matchedTerms: item.terms,
          isSelected: false
        )
      }
      .buttonStyle(.plain)
      .highPriorityGesture(
        LongPressGesture(minimumDuration: 0.5)
          .onEnded { _ in
            viewModel.enterSelectionMode()
            viewModel.toggleSelection(item.record.assetID)
          }
      )
    }
  }

  // MARK: - Empty States

  private var noScreenshotsEmptyState: some View {
    ContentUnavailableView {
      Label("No Screenshots Indexed", systemImage: "photo.on.rectangle.angled")
    } description: {
      Text(
        "Open Settings and tap \"Index New Screenshots\" to start searching your screenshots."
      )
    } actions: {
      Button("Open Settings") { viewModel.showSettings = true }
        .buttonStyle(.borderedProminent)
    }
    .padding(.top, 40)
  }

  // MARK: - Search Results

  @ViewBuilder
  private var searchResultsView: some View {
    if viewModel.searchResults.isEmpty {
      ContentUnavailableView.search(text: viewModel.searchText)
    } else {
      ScrollView {
        flatGrid(
          items: viewModel.searchResults.map {
            CellItem(record: $0.record, terms: $0.matchedTerms)
          }
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
      }
    }
  }

  // MARK: - Grid Helper

  private struct CellItem {
    let record: ScreenshotRecord
    let terms: [String]
  }

  // MARK: - Status Banners

  @ViewBuilder
  private var indexingStatusBanner: some View {
    switch viewModel.indexingState {
    case .requestingPermission:
      StatusBanner(
        icon: "lock.shield",
        title: "Requesting permission…",
        color: .blue
      )
    case .indexing(let prog):
      IndexingProgressBanner(progress: prog)
    case .permissionDenied:
      PermissionDeniedBanner()
    case .failed:
      StatusBanner(
        icon: "exclamationmark.triangle",
        title: "Indexing failed. Please try again in Settings.",
        color: .red
      )
    case .idle where records.isEmpty:
      StatusBanner(
        icon: "photo.stack",
        title: "Tap the settings gear to index your screenshots",
        color: .blue
      )
    default:
      EmptyView()
    }
  }

  @ViewBuilder
  private var limitedAccessBanner: some View {
    if viewModel.isLimitedPhotoAccess,
      case .completed = viewModel.indexingState
    {
      LimitedAccessBanner()
    }
  }

  @ViewBuilder
  private var freeLimitBanner: some View {
    if viewModel.isAtFreeLimit(
      recordsCount: records.count,
      isPro: purchaseManager.isPro
    ) {
      Button {
        viewModel.showPaywall = true
      } label: {
        HStack {
          Label(
            "50 screenshots indexed — unlock unlimited",
            systemImage: "sparkles"
          )
          .font(.subheadline.weight(.medium))
          .multilineTextAlignment(.leading)
          Spacer()
          Image(systemName: "chevron.right")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(
          .yellow.opacity(0.12),
          in: RoundedRectangle(cornerRadius: 12)
        )
        .foregroundStyle(.primary)
      }
    }
  }
}

// MARK: - Shared Banner Components

private struct StatusBanner: View {
  let icon: String
  let title: LocalizedStringKey
  let color: Color

  var body: some View {
    Label(title, systemImage: icon)
      .font(.subheadline)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(12)
      .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
      .foregroundStyle(color)
  }
}

private struct IndexingProgressBanner: View {
  let progress: IndexingProgress

  var body: some View {
    VStack(spacing: 6) {
      HStack {
        Label(
          "Indexing screenshots…",
          systemImage: "waveform.and.magnifyingglass"
        )
        .font(.subheadline.weight(.medium))
        Spacer()
        Text("\(progress.completed) / \(progress.total)")
          .font(.subheadline.monospacedDigit())
          .foregroundStyle(.secondary)
      }
      ProgressView(value: progress.fraction)
        .tint(.blue)
    }
    .padding(12)
    .background(.blue.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
  }
}

private struct PermissionDeniedBanner: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Label("Photos Access Denied", systemImage: "exclamationmark.lock.fill")
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.orange)

      Text(
        "SnapFound needs access to your Photos library to index screenshots. All processing stays on your device — nothing is uploaded."
      )
      .font(.caption)
      .foregroundStyle(.secondary)

      Button {
        if let url = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(url)
        }
      } label: {
        Label("Open Settings", systemImage: "gear")
          .font(.subheadline.weight(.medium))
          .frame(maxWidth: .infinity)
          .padding(.vertical, 10)
          .background(
            .orange.opacity(0.15),
            in: RoundedRectangle(cornerRadius: 10)
          )
          .foregroundStyle(.orange)
      }
    }
    .padding(12)
    .background(.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
  }
}

private struct LimitedAccessBanner: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Label("Limited Photos Access", systemImage: "photo.badge.checkmark")
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.blue)

      Text(
        "Only selected photos are accessible. You can allow access to more screenshots in Settings › Privacy & Security › Photos."
      )
      .font(.caption)
      .foregroundStyle(.secondary)

      Button {
        if let url = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(url)
        }
      } label: {
        Text("Allow More in Settings")
          .font(.caption.weight(.medium))
          .foregroundStyle(.blue)
      }
    }
    .padding(12)
    .background(.blue.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
  }
}

// MARK: - Previews

#Preview("Empty") {
  HomeView()
    .environment(PurchaseManager())
    .modelContainer(for: ScreenshotRecord.self, inMemory: true)
}

#Preview("Banners") {
  VStack(spacing: 12) {
    StatusBanner(
      icon: "photo.stack", title: "Tap the settings gear to index your screenshots", color: .blue)
    IndexingProgressBanner(
      progress: IndexingProgress(total: 120, completed: 45, currentAssetID: nil))
    PermissionDeniedBanner()
    LimitedAccessBanner()
  }
  .padding()
}
