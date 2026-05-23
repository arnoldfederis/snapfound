import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct DetailView: View {
  let records: [ScreenshotRecord]
  let initialRecord: ScreenshotRecord

  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss

  @State private var currentIndex: Int
  @State private var backgroundOpacity: Double = 1
  @State private var currentPageImage: UIImage?
  @State private var showInfo = false
  @State private var filmstripDragging = false
  @State private var isFullscreen = false

  init(record: ScreenshotRecord, allRecords: [ScreenshotRecord] = []) {
    self.initialRecord = record
    let list = allRecords.isEmpty ? [record] : allRecords
    self.records = list
    let idx = list.firstIndex(where: { $0.assetID == record.assetID }) ?? 0
    self._currentIndex = State(initialValue: idx)
  }

  private var currentRecord: ScreenshotRecord {
    guard currentIndex >= 0, currentIndex < records.count else { return initialRecord }
    return records[currentIndex]
  }

  var body: some View {
    TabView(selection: $currentIndex) {
      ForEach(Array(records.enumerated()), id: \.element.assetID) { idx, record in
        PhotoPageView(
          record: record,
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
            withAnimation(.easeInOut(duration: 0.2)) { isFullscreen.toggle() }
          }
        )
        .tag(idx)
      }
    }
    .tabViewStyle(.page(indexDisplayMode: .never))
    // Disable TabView page animation while filmstrip is being dragged
    // so the photo updates instantly instead of trying to animate through pages.
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
        .transition(.move(edge: .bottom).combined(with: .opacity))
      }
    }
    .onChange(of: currentIndex) { _, _ in
      currentPageImage = nil
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
          if let image = currentPageImage {
            let item = TransferableImage(uiImage: image)
            let preview = SharePreview(
              currentRecord.creationDate.shortDisplay,
              image: Image(uiImage: image)
            )
            if currentRecord.ocrText.isEmpty {
              ShareLink(item: item, preview: preview) {
                Label("Share", systemImage: "square.and.arrow.up")
              }
            } else {
              ShareLink(
                item: item,
                message: Text(currentRecord.ocrText),
                preview: preview
              ) {
                Label("Share", systemImage: "square.and.arrow.up")
              }
            }
          } else {
            Label("Share", systemImage: "square.and.arrow.up")
              .foregroundStyle(.secondary)
          }
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
            ThumbnailView(data: record.thumbnailData)
              .scaledToFit()
              .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
              .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                  .stroke(Color(.separator), lineWidth: 0.5)
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
      // Sync when main photo is swiped (TabView updates currentIndex)
      guard !isDragging else { return }
      withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
        displayedIndex = CGFloat(newIdx)
      }
      // Bounce the newly selected thumbnail
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
        let clamped = max(0, min(CGFloat(records.count - 1), rawIndex))
        displayedIndex = clamped

        let liveIndex = Int(round(clamped))
        if liveIndex != currentIndex {
          // Update photo instantly — TabView animation suppressed via .transaction in DetailView
          withTransaction(Transaction(animation: nil)) { currentIndex = liveIndex }
          Haptics.impact(.light)
        }
      }
      .onEnded { value in
        let rawIndex = CGFloat(dragStartIndex) - value.translation.width / totalItemWidth
        let finalIndex = max(0, min(records.count - 1, Int(round(rawIndex))))

        // Snap filmstrip strip to nearest item
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
          displayedIndex = CGFloat(finalIndex)
        }
        // Bounce-zoom the selected thumbnail
        withAnimation(.spring(response: 0.28, dampingFraction: 0.4)) {
          thumbScale = 1.08
        }

        withTransaction(Transaction(animation: nil)) { currentIndex = finalIndex }

        isDragging = false
        Haptics.selection()
      }
  }
}
