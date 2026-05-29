import SwiftUI

struct SearchTabView: View {
  let records: [ScreenshotRecord]
  let viewModel: HomeViewModel

  @Environment(PurchaseManager.self) private var purchaseManager

  @State private var showClearRecentlyAlert = false
  @State private var now = Date()

  private let searchSuggestions = [
    "Receipts", "Wi-Fi password", "Flight", "Hotel booking",
    "Order confirmation", "Error message", "Verification code",
    "Tracking number", "Map", "Meeting notes",
  ]

  var body: some View {
    content
      .navigationTitle(searchNavigationTitle)
      .onAppear { now = Date() }
      .alert("Clear Recently Opened?", isPresented: $showClearRecentlyAlert) {
        Button("Clear All", role: .destructive) { viewModel.clearRecentlyOpened() }
        Button("Cancel", role: .cancel) {}
      } message: {
        Text("This will remove all items from your recently opened history.")
      }
  }

  private var recentlyOpenedRecords: [(record: ScreenshotRecord, openedAt: Date)] {
    viewModel.recentlyOpened.compactMap { entry in
      guard let record = records.first(where: { $0.assetID == entry.assetID }) else { return nil }
      return (record: record, openedAt: entry.openedAt)
    }
  }

  @ViewBuilder
  private var content: some View {
    Group {
      if viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        searchSuggestionsView
      } else if viewModel.searchResults.isEmpty {
        ContentUnavailableView.search(text: viewModel.searchText)
      } else {
        SearchResultsGridView(results: viewModel.searchResults)
      }
    }
    .searchable(
      text: Binding(
        get: { viewModel.searchText },
        set: { viewModel.searchText = $0 }
      ),
      placement: .navigationBarDrawer(displayMode: .always),
      prompt: "Search text from your indexed screenshots…"
    )
  }

  private var searchNavigationTitle: String {
    if viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      return "SnapFound"
    }
    let count = viewModel.searchResults.count
    return "\(count) \(count == 1 ? "Result" : "Results")"
  }

  private var searchSuggestionsView: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        Group {
          indexingStatusBanner
          limitedAccessBanner
          freeLimitBanner
        }
        .padding(.horizontal, 16)

        if !recentlyOpenedRecords.isEmpty {
          VStack(alignment: .leading, spacing: 10) {
            HStack {
              Text("Recently Opened")
                .font(.headline)
                .foregroundStyle(.secondary)
              Spacer()
              Button("Clear All") {
                Haptics.selection()
                showClearRecentlyAlert = true
              }
              .font(.subheadline)
              .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal) {
              LazyHStack(spacing: 12) {
                ForEach(recentlyOpenedRecords, id: \.record.assetID) { item in
                  NavigationLink(value: item.record) {
                    RecentlyOpenedCard(record: item.record, openedAt: item.openedAt, now: now)
                  }
                  .buttonStyle(.plain)
                  .simultaneousGesture(TapGesture().onEnded { Haptics.impact(.light) })
                }
              }
              .scrollTargetLayout()
              .padding(.horizontal, 16)
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
          }
        }

        VStack(alignment: .leading, spacing: 12) {
          Text("Suggestions")
            .font(.headline)
            .foregroundStyle(.secondary)

          FlowLayout(spacing: 8) {
            ForEach(searchSuggestions, id: \.self) { suggestion in
              Button {
                Haptics.selection()
                viewModel.searchText = suggestion
              } label: {
                Text(suggestion)
                  .padding(.horizontal, 10)
                  .padding(.vertical, 6)
                  .background(Color.accentColor.opacity(0.15), in: Capsule())
                  .foregroundStyle(Color.accentColor)
              }
              .buttonStyle(.plain)
            }
          }
        }
        .padding(.horizontal, 16)
      }
    }
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

fileprivate struct RecentlyOpenedCard: View {
  let record: ScreenshotRecord
  let openedAt: Date
  let now: Date

  private var label: String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .abbreviated
    return formatter.localizedString(for: openedAt, relativeTo: now)
  }

  var body: some View {
    VStack(alignment: .center, spacing: 6) {
      Group {
        if let data = record.thumbnailData, let image = UIImage(data: data) {
          Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
        } else {
          Rectangle()
            .fill(.quaternary)
            .overlay {
              Image(systemName: "photo").foregroundStyle(.tertiary).font(.title2)
            }
        }
      }
      .frame(width: 100, height: 160)
      .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

      Text(label)
        .font(.caption2)
        .foregroundStyle(.secondary)
        .lineLimit(1)
        .frame(width: 100, alignment: .center)
        .multilineTextAlignment(.center)
    }
  }
}

fileprivate struct SearchResultsGridView: View {
  let results: [SearchResult]

  var body: some View {
    ScrollView {
      LazyVGrid(
        columns: Array(
          repeating: GridItem(.flexible(), spacing: GridZoomLevel.comfortable.spacing), count: 3),
        spacing: GridZoomLevel.comfortable.spacing
      ) {
        ForEach(results) { result in
          NavigationLink(value: result.record) {
            ScreenshotGridCell(
              record: result.record,
              matchedTerms: result.matchedTerms,
              isSelected: false
            )
          }
          .buttonStyle(.plain)
          .contentShape(Rectangle())
          .simultaneousGesture(TapGesture().onEnded { Haptics.impact(.light) })
          .id(result.record.assetID)
        }
      }
      .padding(.horizontal, 16)
      .padding(.top, 8)
    }
  }
}
