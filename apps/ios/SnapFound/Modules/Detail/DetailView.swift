import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct DetailView: View {
  let records: [ScreenshotRecord]
  let initialRecord: ScreenshotRecord
  let onPageChanged: ((String) -> Void)?

  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  @State private var currentIndex: Int
  @State private var scrollPositionID: String?
  @State private var backgroundOpacity: Double = 1
  @State private var currentPageImage: UIImage?
  @State private var showInfo = false
  @State private var isFullscreen = false
  @State private var showDeleteConfirm = false

  init(
    record: ScreenshotRecord, allRecords: [ScreenshotRecord] = [],
    onPageChanged: ((String) -> Void)? = nil
  ) {
    self.initialRecord = record
    self.onPageChanged = onPageChanged
    let list = allRecords.isEmpty ? [record] : allRecords
    self.records = list
    let idx = list.firstIndex(where: { $0.assetID == record.assetID }) ?? 0
    self._currentIndex = State(initialValue: idx)
    self._scrollPositionID = State(initialValue: record.assetID)
  }

  private var currentRecord: ScreenshotRecord {
    guard currentIndex >= 0, currentIndex < records.count else { return initialRecord }
    return records[currentIndex]
  }

  @ViewBuilder
  private var shareMenuItems: some View {
    if let image = currentPageImage {
      let item = TransferableImage(uiImage: image)
      let preview = SharePreview(
        currentRecord.creationDate.shortDisplay, image: Image(uiImage: image))
      if currentRecord.ocrText.isEmpty {
        ShareLink(item: item, preview: preview) {
          Label("Share", systemImage: "square.and.arrow.up")
        }
      } else {
        ShareLink(item: item, message: Text(currentRecord.ocrText), preview: preview) {
          Label("Share", systemImage: "square.and.arrow.up")
        }
      }
    } else {
      Label("Share", systemImage: "square.and.arrow.up")
        .foregroundStyle(.secondary)
    }
  }

  // MARK: - Pager

  // .ignoresSafeArea(edges:) with an empty set is a no-op, so we keep the same
  // view instance in both states — SwiftUI can then animate the safe-area inset
  // change smoothly rather than destroying/recreating the view.
  private var pagerView: some View {
    mainPager
      .ignoresSafeArea(edges: isFullscreen && currentRecord.height == 0 ? .all : [])
  }

  private var mainPager: some View {
    GeometryReader { geo in
      ScrollView(.horizontal) {
        LazyHStack(spacing: 0) {
          ForEach(Array(records.enumerated()), id: \.element.assetID) { idx, record in
            PhotoPageView(
              record: record,
              isFullscreen: isFullscreen,
              isCurrentPage: idx == currentIndex,
              onSwipeUp: {
                showInfo = true
                Haptics.impact(.light)
              },
              onDismiss: { dismiss() },
              onDismissProgress: { progress in
                backgroundOpacity = max(0.05, 1 - progress * 0.85)
              },
              onImageLoaded: { img in
                if idx == currentIndex { currentPageImage = img }
              },
              onSingleTap: {
                guard record.height == 0 else { return }
                withAnimation(.easeInOut(duration: 0.25)) { isFullscreen.toggle() }
              }
            )
            .padding(.horizontal, record.height > 0 ? 16 : 0)
            .frame(width: geo.size.width, height: geo.size.height)
            .id(record.assetID)
          }
        }
        .scrollTargetLayout()
      }
      .scrollTargetBehavior(.paging)
      .scrollIndicators(.hidden)
      .scrollPosition(id: $scrollPositionID)
      .onChange(of: scrollPositionID) { _, id in
        guard let id, let idx = records.firstIndex(where: { $0.assetID == id }),
          idx != currentIndex
        else { return }
        currentIndex = idx
      }
      .onChange(of: currentIndex) { _, idx in
        currentPageImage = nil
        guard idx >= 0, idx < records.count else { return }
        Haptics.selection()
        let record = records[idx]
        onPageChanged?(record.assetID)
        if record.height > 0 { isFullscreen = false }
        let newID = record.assetID
        guard newID != scrollPositionID else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
          scrollPositionID = newID
        }
      }
    }
  }

  var body: some View {
    pagerView
      .onAppear {
        onPageChanged?(currentRecord.assetID)
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar(horizontalSizeClass == .compact ? .hidden : .visible, for: .tabBar)
      .toolbar(isFullscreen ? .hidden : .visible, for: .navigationBar)
      .toolbar(isFullscreen ? .hidden : .visible, for: .bottomBar)
      .toolbar {
        if UIDevice.current.userInterfaceIdiom == .phone {
          ToolbarItem(placement: .principal) {
            Button {
              showInfo = true
              Haptics.impact(.light)
            } label: {
              VStack(spacing: 2) {
                Text(currentRecord.creationDate.smartDisplayString())
                  .font(.caption)
                  .fontWeight(.semibold)
                Text(currentRecord.creationDate, format: .dateTime.hour().minute())
                  .font(.caption2)
                  .fontWeight(.semibold)
                  .foregroundStyle(.secondary)
              }
              .padding(.horizontal, 46)
            }
            .buttonStyle(.glass)
          }
        }

        ToolbarItem(placement: .topBarTrailing) {
          Button {
            showInfo = true
            Haptics.impact(.light)
          } label: {
            Image(systemName: "info.circle")
          }
        }
        ToolbarItemGroup(placement: .bottomBar) {
          shareMenuItems
          if UIDevice.current.userInterfaceIdiom == .phone {
            Spacer()
          } else {
            Spacer()
            Button {
              showInfo = true
              Haptics.impact(.light)
            } label: {
              VStack(spacing: 2) {
                Text(currentRecord.creationDate.smartDisplayString())
                  .font(.caption)
                  .fontWeight(.semibold)
                Text(currentRecord.creationDate, format: .dateTime.hour().minute())
                  .font(.caption2)
                  .fontWeight(.semibold)
                  .foregroundStyle(.secondary)
              }
              .padding(.horizontal, 46)
            }
            Spacer()
          }
          Button {
            showDeleteConfirm = true
            Haptics.notification(.warning)
          } label: {
            Label("Remove from Index", systemImage: "trash")
          }
          .tint(.red)
          .confirmationDialog(
            "Remove from Index?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
          ) {
            Button("Remove", role: .destructive) {
              modelContext.delete(currentRecord)
              try? modelContext.save()
              dismiss()
            }
            Button("Cancel", role: .cancel) {}
          } message: {
            Text("This screenshot will be removed from the search index.")
          }
        }
      }
      .sheet(isPresented: $showInfo) {
        DetailInfoPanel(record: currentRecord, image: currentPageImage) {
          modelContext.delete(currentRecord)
          try? modelContext.save()
          dismiss()
        }
      }
  }
}

// MARK: - Transferable image wrapper

private struct TransferableImage: Transferable {
  let uiImage: UIImage

  static var transferRepresentation: some TransferRepresentation {
    DataRepresentation(exportedContentType: .png) {
      $0.uiImage.pngData() ?? Data()
    }
  }
}

// MARK: - Preview

#Preview {
  let record = ScreenshotRecord(
    assetID: "preview-1",
    creationDate: .now,
    ocrText: "Sample OCR text from a screenshot",
    tags: ["receipt"],
    width: 390,
    height: 844,
    thumbnailData: nil
  )
  NavigationStack {
    DetailView(record: record)
  }
  .modelContainer(for: ScreenshotRecord.self, inMemory: true)
}
