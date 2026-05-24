import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct DetailView: View {
  let records: [ScreenshotRecord]
  let initialRecord: ScreenshotRecord
  let onPageChanged: ((String) -> Void)?

  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss

  @State private var currentIndex: Int
  @State private var scrollPositionID: String?
  @State private var backgroundOpacity: Double = 1
  @State private var currentPageImage: UIImage?
  @State private var showInfo = false
  @State private var filmstripDragging = false
  @State private var isFullscreen = false

  init(record: ScreenshotRecord, allRecords: [ScreenshotRecord] = [], onPageChanged: ((String) -> Void)? = nil) {
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
      let preview = SharePreview(currentRecord.creationDate.shortDisplay, image: Image(uiImage: image))
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
    ScrollView(.horizontal) {
      LazyHStack(spacing: 0) {
        ForEach(Array(records.enumerated()), id: \.element.assetID) { idx, record in
          PhotoPageView(
            record: record,
            isFullscreen: isFullscreen,
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
              // Only height==0 images (unknown aspect) toggle fullscreen
              guard record.height == 0 else { return }
              withAnimation(.easeInOut(duration: 0.25)) { isFullscreen.toggle() }
            }
          )
          .containerRelativeFrame([.horizontal, .vertical])
          .id(record.assetID)
        }
      }
      .scrollTargetLayout()
    }
    .scrollTargetBehavior(.paging)
    .scrollIndicators(.hidden)
    .scrollPosition(id: $scrollPositionID)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .transaction(value: currentIndex) { t in
      if filmstripDragging { t.animation = nil }
    }
    .safeAreaInset(edge: .bottom) {
      if !isFullscreen {
        FilmstripBar(
          records: records,
          currentIndex: $currentIndex,
          isDragging: $filmstripDragging
        )
        .transition(.opacity)
      }
    }
    .onChange(of: scrollPositionID) { _, id in
      guard let id, let idx = records.firstIndex(where: { $0.assetID == id }), idx != currentIndex else { return }
      currentIndex = idx
    }
    .onChange(of: currentIndex) { _, idx in
      currentPageImage = nil
      guard idx >= 0, idx < records.count else { return }
      let record = records[idx]
      onPageChanged?(record.assetID)
      if record.height > 0 { isFullscreen = false }
      let newID = record.assetID
      guard newID != scrollPositionID else { return }
      if filmstripDragging {
        var t = Transaction()
        t.animation = nil
        withTransaction(t) { scrollPositionID = newID }
      } else {
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
      .navigationTitle(currentRecord.creationDate.shortDisplay)
      .navigationBarTitleDisplayMode(.inline)
      .toolbarColorScheme(.dark, for: .navigationBar)
      .toolbar(isFullscreen ? .hidden : .visible, for: .navigationBar)
      .toolbar(.hidden, for: .bottomBar)
      .toolbar {
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
        ToolbarItem(placement: .topBarTrailing) {
          Menu {
            shareMenuItems
            Button(role: .destructive) {
              modelContext.delete(currentRecord)
              try? modelContext.save()
              dismiss()
            } label: {
              Label("Remove from Index", systemImage: "trash")
            }
          } label: {
            Image(systemName: "ellipsis.circle")
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

// MARK: - Photo Page

private struct PhotoPageView: View {
  let record: ScreenshotRecord
  let isFullscreen: Bool
  let onSwipeUp: () -> Void
  let onDismiss: () -> Void
  let onDismissProgress: (Double) -> Void
  let onImageLoaded: (UIImage) -> Void
  let onSingleTap: () -> Void

  @State private var viewModel = DetailViewModel()

  var body: some View {
    Group {
      if let image = viewModel.fullImage {
        ZoomableImageView(
          image: image,
          onSwipeUp: onSwipeUp,
          onDismiss: onDismiss,
          onDismissProgress: onDismissProgress,
          onSingleTap: onSingleTap
        )
      } else {
        ZStack {
          if record.height == 0 {
            if isFullscreen {
              ThumbnailView(data: record.thumbnailData)
                .scaledToFit()
            } else {
              ThumbnailView(data: record.thumbnailData)
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay {
                  RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color(.separator), lineWidth: 0.5)
                }
            }
          } else {
            ThumbnailView(data: record.thumbnailData)
              .scaledToFit()
          }
          if viewModel.isLoadingImage {
            ProgressView().tint(.white)
          }
        }
      }
    }
    .task {
      guard viewModel.fullImage == nil else { return }
      await viewModel.loadImage(for: record)
      if let img = viewModel.fullImage { onImageLoaded(img) }
    }
  }
}

// MARK: - Filmstrip

private struct FilmstripBar: View {
  let records: [ScreenshotRecord]
  @Binding var currentIndex: Int
  @Binding var isDragging: Bool

  @State private var displayedIndex: CGFloat
  @State private var dragStartIndex: Int = 0
  @State private var thumbScale: CGFloat = 1.08

  private let itemWidth: CGFloat = 52
  private let itemSpacing: CGFloat = 6
  private var totalItemWidth: CGFloat { itemWidth + itemSpacing }

  init(
    records: [ScreenshotRecord],
    currentIndex: Binding<Int>,
    isDragging: Binding<Bool>
  ) {
    self.records = records
    self._currentIndex = currentIndex
    self._isDragging = isDragging
    self._displayedIndex = State(initialValue: CGFloat(currentIndex.wrappedValue))
    self._dragStartIndex = State(initialValue: currentIndex.wrappedValue)
  }

  var body: some View {
    GeometryReader { geo in
      HStack(spacing: itemSpacing) {
        ForEach(Array(records.enumerated()), id: \.element.assetID) { idx, record in
          let isSelected = idx == currentIndex
          ThumbnailView(data: record.thumbnailData)
            .frame(width: itemWidth, height: itemWidth)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay {
              if isSelected {
                RoundedRectangle(cornerRadius: 6)
                  .stroke(Color.white, lineWidth: 2.5)
              }
            }
            .opacity(isSelected ? 1.0 : 0.55)
            .scaleEffect(isSelected ? thumbScale : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
            .onTapGesture { selectThumbnail(at: idx) }
        }
      }
      .offset(
        x: geo.size.width / 2 - itemWidth / 2 - displayedIndex * totalItemWidth,
        y: (geo.size.height - itemWidth) / 2
      )
    }
    .frame(height: 70)
    .background(.ultraThinMaterial.opacity(0.95))
    .environment(\.colorScheme, .dark)
    .clipped()
    .gesture(filmstripDrag)
    .onChange(of: currentIndex) { _, newIdx in
      guard !isDragging else { return }
      withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
        displayedIndex = CGFloat(newIdx)
      }
      withAnimation(.spring(response: 0.28, dampingFraction: 0.4)) {
        thumbScale = 1.08
      }
    }
  }

  private func selectThumbnail(at idx: Int) {
    currentIndex = idx
    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
      displayedIndex = CGFloat(idx)
    }
    withAnimation(.spring(response: 0.28, dampingFraction: 0.4)) {
      thumbScale = 1.08
    }
    Haptics.selection()
  }

  private var filmstripDrag: some Gesture {
    DragGesture(minimumDistance: 5, coordinateSpace: .local)
      .onChanged { value in
        if !isDragging {
          isDragging = true
          dragStartIndex = currentIndex
          withAnimation(.easeOut(duration: 0.1)) { thumbScale = 1.0 }
        }

        let rawIndex = CGFloat(dragStartIndex) - value.translation.width / totalItemWidth
        let maxIdx = CGFloat(records.count - 1)

        // Rubber-band resistance beyond first/last item
        let clamped: CGFloat
        if rawIndex < 0 {
          clamped = rawIndex * 0.2
        } else if rawIndex > maxIdx {
          clamped = maxIdx + (rawIndex - maxIdx) * 0.2
        } else {
          clamped = rawIndex
        }
        displayedIndex = clamped

        let liveIndex = Int(round(max(0, min(maxIdx, clamped))))
        if liveIndex != currentIndex {
          withTransaction(Transaction(animation: nil)) { currentIndex = liveIndex }
          Haptics.impact(.light)
        }
      }
      .onEnded { value in
        // velocity.width is pts/s; divide by (totalItemWidth * 3) to get item count of momentum.
        // This gives a roulette-style spin: fast flick travels many items, slow drag stops quickly.
        let momentumItems = value.velocity.width / (totalItemWidth * 3)
        let rawIndex = CGFloat(dragStartIndex) - value.translation.width / totalItemWidth - momentumItems
        let finalIndex = max(0, min(records.count - 1, Int(round(rawIndex))))

        // Duration scales with travel distance so the wheel "decelerates" naturally.
        let travelItems = abs(CGFloat(finalIndex) - displayedIndex)
        let duration = min(1.0, max(0.2, Double(travelItems) * 0.055 + 0.2))

        withAnimation(.easeOut(duration: duration)) {
          displayedIndex = CGFloat(finalIndex)
        }
        withAnimation(.spring(response: 0.28, dampingFraction: 0.4)) {
          thumbScale = 1.08
        }

        withTransaction(Transaction(animation: nil)) { currentIndex = finalIndex }

        isDragging = false
        Haptics.selection()
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
