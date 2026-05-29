import SwiftUI

struct PhotoPageView: View {
  let record: ScreenshotRecord
  let isFullscreen: Bool
  let isCurrentPage: Bool
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
              ThumbnailView(data: record.thumbnailData, height: record.height)
                .scaledToFit()
            } else {
              ThumbnailView(data: record.thumbnailData, height: record.height)
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay {
                  RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color(.separator), lineWidth: 0.5)
                }
            }
          } else {
            ThumbnailView(data: record.thumbnailData, height: record.height)
              .scaledToFit()
          }
          if viewModel.isLoadingImage {
            ProgressView().tint(.white)
          }
        }
      }
    }
    .task {
      if viewModel.fullImage == nil {
        await viewModel.loadImage(for: record)
      }
      if let img = viewModel.fullImage { onImageLoaded(img) }
    }
    .onChange(of: isCurrentPage) { _, isCurrent in
      if isCurrent, let img = viewModel.fullImage { onImageLoaded(img) }
    }
  }
}
