import SwiftData
import SwiftUI

struct HomeLibraryTabView: View {
  @Environment(\.modelContext) private var modelContext
  let records: [ScreenshotRecord]
  let viewModel: HomeViewModel
  let zoomLevel: GridZoomLevel
  @Binding var zoomLevelRaw: Int
  let openSettings: () -> Void

  @Environment(PurchaseManager.self) private var purchaseManager

  var body: some View {
    mainGridView
      .navigationTitle(navigationTitle)
      .toolbar(viewModel.isSelectionMode ? .hidden : .visible, for: .tabBar)
      .animation(.snappy(duration: 0.25), value: viewModel.isSelectionMode)
      .toolbar {
        ToolbarItemGroup(placement: .bottomBar) {
          if viewModel.isSelectionMode {
            Button {
              Task { await viewModel.shareSelected(records: records) }
            } label: {
              if viewModel.isPreparingShare {
                Label("Preparing...", systemImage: "hourglass")
              } else {
                Label("Share", systemImage: "square.and.arrow.up")
              }
            }
            .disabled(viewModel.selectedIDs.isEmpty || viewModel.isPreparingShare)

            Spacer()

            Button {
              viewModel.showDeleteSelected = true
              Haptics.notification(.warning)
            } label: {
              Label("Delete", systemImage: "trash")
            }
            .disabled(viewModel.selectedIDs.isEmpty)
            .tint(.red)
            .confirmationDialog(
              "Delete \(viewModel.selectedIDs.count) Screenshots from Index?",
              isPresented: Binding(
                get: { viewModel.showDeleteSelected },
                set: { viewModel.showDeleteSelected = $0 }
              ),
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
                "The selected screenshots will be removed from the local search index. Your photos will not be deleted."
              )
            }
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
    return "Screenshots"
  }

  // MARK: - Main Grid

  private var mainGridView: some View {
    ScrollViewReader { proxy in
      ScrollView {
        VStack {
          if records.isEmpty {
            noScreenshotsEmptyState
          } else if zoomLevel.isGrouped {
            groupedGridView
          } else {
            flatGrid(items: records.map { CellItem(record: $0, terms: []) })
          }
        }
        .id("grid-top")
        .padding(.horizontal, zoomLevel == .compact ? 6 : 16)
      }
      .onAppear {
        if let id = viewModel.lastViewedAssetID {
          DispatchQueue.main.async { proxy.scrollTo(id, anchor: .center) }
          viewModel.lastViewedAssetID = nil
        }
      }
      .onChange(of: zoomLevelRaw) {
        Haptics.selection()
        DispatchQueue.main.async { proxy.scrollTo("grid-top", anchor: .top) }
      }
    }
  }

  // MARK: - Grouped Grid

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
        cell(for: item).id(item.record.assetID)
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
      .contentShape(Rectangle())
    } else {
      NavigationLink(value: item.record) {
        ScreenshotGridCell(
          record: item.record,
          matchedTerms: item.terms,
          isSelected: false
        )
      }
      .buttonStyle(.plain)
      .contentShape(Rectangle())
      .simultaneousGesture(TapGesture().onEnded { Haptics.impact(.light) })
    }
  }

  // MARK: - Empty State

  private var noScreenshotsEmptyState: some View {
    ContentUnavailableView {
      Label(noScreenshotsEmptyStateTitle, systemImage: "photo.on.rectangle.angled")
    } description: {
      Text(noScreenshotsEmptyStateDescription)
    } actions: {
      Button("Open Settings") { openSettings() }
        .buttonStyle(.borderedProminent)
    }
    .padding(.top, 40)
  }

  private var noScreenshotsEmptyStateTitle: String {
    if case .completed(0) = viewModel.indexingState { return "No Screenshots Found" }
    return "No Screenshots Indexed"
  }

  private var noScreenshotsEmptyStateDescription: String {
    if case .completed(0) = viewModel.indexingState {
      return "SnapFound searches screenshots only. It did not find any accessible screenshots in Photos."
    }
    return "Open Settings and tap \"Index New Screenshots\" to start searching your screenshots."
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
      StatusBanner(icon: "lock.shield", title: "Requesting permission…", color: .accent)
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
    case .paused(let reason):
      StatusBanner(icon: "pause.circle", title: LocalizedStringKey(reason), color: .orange)
    case .idle where records.isEmpty:
      StatusBanner(
        icon: "photo.stack",
        title: "Open Settings to index your screenshots",
        color: .accent
      )
    case .freeLimitReached:
      EmptyView()
    default:
      EmptyView()
    }
  }

  @ViewBuilder
  private var limitedAccessBanner: some View {
    if viewModel.isLimitedPhotoAccess, case .completed = viewModel.indexingState {
      LimitedAccessBanner()
    }
  }

  @ViewBuilder
  private var freeLimitBanner: some View {
    if viewModel.isAtFreeLimit(recordsCount: records.count, isPro: purchaseManager.isPro) {
      Button {
        Haptics.impact(.light)
        viewModel.showPaywall = true
      } label: {
        HStack {
          Label("50 screenshots indexed - unlock unlimited", systemImage: "sparkles")
            .font(.subheadline.weight(.medium))
            .multilineTextAlignment(.leading)
          Spacer()
          Image(systemName: "chevron.right")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(.accent.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
        .foregroundStyle(.accent)
      }
    }
  }
}

// MARK: - Banner Components

struct StatusBanner: View {
  let icon: String
  let title: LocalizedStringKey
  let color: Color

  var body: some View {
    Label(title, systemImage: icon)
      .font(.subheadline)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(12)
      .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
      .foregroundStyle(color)
  }
}

struct IndexingProgressBanner: View {
  let progress: IndexingProgress

  var body: some View {
    VStack(spacing: 6) {
      HStack {
        Label("Indexing screenshots…", systemImage: "waveform.and.magnifyingglass")
          .foregroundStyle(.accent)
          .font(.subheadline.weight(.medium))
        Spacer()
        Text("\(progress.completed) / \(progress.total)")
          .font(.subheadline.monospacedDigit())
          .foregroundStyle(.accent)
      }
      ProgressView(value: progress.fraction)
        .tint(.accent)
    }
    .padding(12)
    .background(.accent.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
  }
}

struct PermissionDeniedBanner: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Label("Photos Access Denied", systemImage: "exclamationmark.lock.fill")
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.orange)

      Text(
        "SnapFound needs Photos access to index screenshots. All processing stays on your device and nothing is uploaded."
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
          .background(.orange.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
          .foregroundStyle(.orange)
      }
    }
    .padding(12)
    .background(.orange.opacity(0.18), in: RoundedRectangle(cornerRadius: 12))
  }
}

struct LimitedAccessBanner: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Label("Limited Photos Access", systemImage: "photo.badge.checkmark")
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.yellow)

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
        Label("Allow More in Settings", systemImage: "gear")
          .font(.subheadline.weight(.medium))
          .frame(maxWidth: .infinity)
          .padding(.vertical, 10)
          .background(.yellow.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
          .foregroundStyle(.yellow)
      }
    }
    .padding(12)
    .background(.yellow.opacity(0.18), in: RoundedRectangle(cornerRadius: 12))
  }
}

#Preview("Banners") {
  VStack(spacing: 12) {
    StatusBanner(
      icon: "photo.stack", title: "Tap the settings gear to index your screenshots", color: .accent)
    IndexingProgressBanner(
      progress: IndexingProgress(total: 120, completed: 45, currentAssetID: nil))
    PermissionDeniedBanner()
    LimitedAccessBanner()
  }
  .padding()
}
