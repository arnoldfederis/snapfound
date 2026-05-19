import SwiftData
import SwiftUI

struct HomeView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(PurchaseManager.self) private var purchaseManager
  @Query(sort: \ScreenshotRecord.creationDate, order: .reverse)
  private var records: [ScreenshotRecord]

  @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
  @State private var viewModel = HomeViewModel()
  @State private var showOnboarding = false

  private let columns = [
    GridItem(.flexible(), spacing: 10),
    GridItem(.flexible(), spacing: 10),
    GridItem(.flexible(), spacing: 10),
  ]

  var body: some View {
    NavigationStack {
      // HomeBodyView is a subview so @Environment(\.isSearching) resolves correctly
      // inside it (isSearching is set by .searchable on the NavigationStack).
      HomeBodyView(
        records: records,
        viewModel: viewModel,
        columns: columns
      )
      .navigationDestination(for: ScreenshotRecord.self) { record in
        DetailView(record: record)
      }
      .navigationTitle("SnapFound")
      .navigationBarTitleDisplayMode(.large)
      .searchable(text: $viewModel.searchText, prompt: "Search screenshots…")
      .onChange(of: viewModel.searchText) {
        viewModel.search(in: records)
      }
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            viewModel.showSettings = true
          } label: {
            Image(systemName: "gear")
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
  let columns: [GridItem]

  @Environment(PurchaseManager.self) private var purchaseManager
  @Environment(\.isSearching) private var isSearching

  private let searchSuggestions = [
    "Receipts", "Wi-Fi password", "Flight", "Hotel booking",
    "Order confirmation", "Error message", "Verification code",
    "Tracking number", "Map", "Meeting notes",
  ]

  var body: some View {
    Group {
      if viewModel.isSearchActive {
        searchResultsView
      } else if isSearching {
        suggestionsView
      } else {
        mainGridView
      }
    }
  }

  // MARK: - Main Grid

  private var mainGridView: some View {
    ScrollView {
      VStack(spacing: 16) {
        indexingStatusBanner
        limitedAccessBanner
        freeLimitBanner

        if records.isEmpty {
          noScreenshotsEmptyState
        } else {
          screenshotGrid(items: records.map { CellItem(record: $0, terms: []) })
        }
      }
      .padding(.horizontal, 16)
      .padding(.top, 8)
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

  // MARK: - Search Suggestions

  private var suggestionsView: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        Text("Suggestions")
          .font(.subheadline.weight(.semibold))
          .foregroundStyle(.secondary)
          .padding(.horizontal, 16)

        FlowLayout(spacing: 8) {
          ForEach(searchSuggestions, id: \.self) { suggestion in
            Button {
              viewModel.searchText = suggestion
            } label: {
              Text(suggestion)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.quaternary, in: Capsule())
                .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)
          }
        }
        .padding(.horizontal, 16)
      }
      .padding(.top, 16)
    }
  }

  // MARK: - Search Results

  @ViewBuilder
  private var searchResultsView: some View {
    if viewModel.searchResults.isEmpty {
      ContentUnavailableView.search(text: viewModel.searchText)
    } else {
      ScrollView {
        screenshotGrid(
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

  private func screenshotGrid(items: [CellItem]) -> some View {
    LazyVGrid(columns: columns, spacing: 10) {
      ForEach(items, id: \.record.assetID) { item in
        NavigationLink(value: item.record) {
          ScreenshotGridCell(
            record: item.record,
            matchedTerms: item.terms
          )
        }
        .buttonStyle(.plain)
      }
    }
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
