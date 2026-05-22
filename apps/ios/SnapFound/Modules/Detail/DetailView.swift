import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct DetailView: View {
  let initialRecord: ScreenshotRecord
  let allRecords: [ScreenshotRecord]

  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss

  @State private var currentIndex: Int
  @State private var backgroundOpacity: Double = 1
  @State private var currentPageImage: UIImage?
  @State private var showInfo = false

  init(record: ScreenshotRecord, allRecords: [ScreenshotRecord]) {
    self.initialRecord = record
    self.allRecords = allRecords.isEmpty ? [record] : allRecords
    let idx = allRecords.firstIndex { $0.assetID == record.assetID } ?? 0
    _currentIndex = State(initialValue: idx)
  }

  private var currentRecord: ScreenshotRecord {
    guard currentIndex < allRecords.count else { return initialRecord }
    return allRecords[currentIndex]
  }

  var body: some View {
    ZStack(alignment: .bottom) {
      Color.black.opacity(backgroundOpacity).ignoresSafeArea()

      pageCarousel

      if allRecords.count > 1 {
        FilmstripBar(records: allRecords, currentIndex: $currentIndex)
          .opacity(backgroundOpacity)
      }
    }
    .navigationTitle(currentRecord.creationDate.shortDisplay)
    .navigationBarTitleDisplayMode(.inline)
    .toolbarColorScheme(.dark, for: .navigationBar, .bottomBar)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        if let image = currentPageImage {
          let item = TransferableImage(uiImage: image)
          let preview = SharePreview(
            currentRecord.creationDate.shortDisplay,
            image: Image(uiImage: image)
          )
          if currentRecord.ocrText.isEmpty {
            ShareLink(item: item, preview: preview)
          } else {
            ShareLink(
              item: item,
              message: Text(currentRecord.ocrText),
              preview: preview
            )
          }
        } else {
          Image(systemName: "square.and.arrow.up")
            .opacity(0.4)
        }
      }
      ToolbarItem(placement: .bottomBar) { Spacer() }
      ToolbarItem(placement: .bottomBar) {
        Button {
          showInfo = true
          Haptics.impact(.light)
        } label: {
          Image(systemName: "info.circle")
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
    .onChange(of: currentIndex) { _, _ in
      currentPageImage = nil
      withAnimation(.easeInOut(duration: 0.15)) {
        backgroundOpacity = 1
      }
    }
  }

  private var pageCarousel: some View {
    TabView(selection: $currentIndex) {
      ForEach(Array(allRecords.enumerated()), id: \.element.assetID) { idx, record in
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
          }
        )
        .tag(idx)
        .ignoresSafeArea()
      }
    }
    .tabViewStyle(.page(indexDisplayMode: .never))
    .ignoresSafeArea()
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

  @State private var viewModel = DetailViewModel()

  var body: some View {
    Group {
      if let image = viewModel.fullImage {
        ZoomableImageView(
          image: image,
          onSwipeUp: onSwipeUp,
          onDismiss: onDismiss,
          onDismissProgress: onDismissProgress
        )
      } else {
        ZStack {
          ThumbnailView(data: record.thumbnailData)
            .scaledToFit()
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

  var body: some View {
    ScrollViewReader { proxy in
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 3) {
          ForEach(Array(records.enumerated()), id: \.element.assetID) { idx, record in
            Button {
              currentIndex = idx
              Haptics.selection()
            } label: {
              ThumbnailView(data: record.thumbnailData)
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 3))
                .overlay {
                  if idx == currentIndex {
                    RoundedRectangle(cornerRadius: 3)
                      .stroke(Color.white, lineWidth: 2)
                  }
                }
                .opacity(idx == currentIndex ? 1 : 0.5)
                .scaleEffect(idx == currentIndex ? 1 : 0.95)
                .animation(.easeInOut(duration: 0.15), value: currentIndex)
            }
            .buttonStyle(.plain)
            .id(idx)
          }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
      }
      .frame(height: 66)
      .background(.ultraThinMaterial.opacity(0.9))
      .environment(\.colorScheme, .dark)
      .onChange(of: currentIndex) { _, newIdx in
        withAnimation(.easeInOut(duration: 0.2)) {
          proxy.scrollTo(newIdx, anchor: .center)
        }
      }
    }
  }
}
