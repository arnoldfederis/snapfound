import SwiftUI

struct ZoomableImageView: View {
  let image: UIImage
  var onSwipeUp: (() -> Void)?
  var onDismiss: (() -> Void)?
  /// Called with 0…1 progress as the user drags down at 1x scale.
  var onDismissProgress: ((Double) -> Void)?

  @State private var zoomScale: CGFloat = 1
  @State private var lastZoomScale: CGFloat = 1
  @State private var panOffset: CGSize = .zero
  @State private var lastPanOffset: CGSize = .zero
  @State private var dismissOffset: CGFloat = 0

  var body: some View {
    Image(uiImage: image)
      .resizable()
      .scaledToFit()
      .scaleEffect(visibleScale)
      .offset(visibleOffset)
      .gesture(magnifyGesture)
      .simultaneousGesture(dragGesture)
      .onTapGesture(count: 2, perform: doubleTap)
  }

  private var visibleScale: CGFloat {
    guard dismissOffset > 0 else { return zoomScale }
    let progress = min(1, dismissOffset / 400)
    return max(0.5, zoomScale * (1 - progress * 0.25))
  }

  private var visibleOffset: CGSize {
    CGSize(width: panOffset.width, height: panOffset.height + dismissOffset)
  }

  private var dismissProgress: Double { min(1, Double(dismissOffset) / 300) }

  // MARK: - Magnify (pinch-to-close when < 0.7x at 1x base)

  private var magnifyGesture: some Gesture {
    MagnifyGesture()
      .onChanged { value in
        zoomScale = max(1, lastZoomScale * value.magnification)
      }
      .onEnded { value in
        let candidate = lastZoomScale * value.magnification
        if candidate < 0.7, lastZoomScale <= 1 {
          onDismiss?()
        } else {
          withAnimation(.spring(duration: 0.2)) {
            zoomScale = max(1, candidate)
            if zoomScale <= 1 {
              panOffset = .zero
              lastPanOffset = .zero
            }
          }
          lastZoomScale = zoomScale
        }
      }
  }

  // MARK: - Drag (pan when zoomed; swipe-down dismiss or swipe-up info when at 1x)

  private var dragGesture: some Gesture {
    DragGesture(minimumDistance: 10)
      .onChanged { value in
        if zoomScale > 1 {
          panOffset = CGSize(
            width: lastPanOffset.width + value.translation.width,
            height: lastPanOffset.height + value.translation.height
          )
        } else if value.translation.height > 0 {
          dismissOffset = value.translation.height
          onDismissProgress?(dismissProgress)
        }
      }
      .onEnded { value in
        if zoomScale > 1 {
          lastPanOffset = panOffset
        } else if value.translation.height < -50 {
          onSwipeUp?()
          resetDismiss()
        } else if value.translation.height > 100 || value.velocity.height > 500 {
          onDismiss?()
        } else {
          resetDismiss()
        }
      }
  }

  private func resetDismiss() {
    withAnimation(.spring(duration: 0.3)) {
      dismissOffset = 0
    }
    onDismissProgress?(0)
  }

  private func doubleTap() {
    withAnimation(.spring(duration: 0.3)) {
      if zoomScale > 1 {
        zoomScale = 1
        lastZoomScale = 1
        panOffset = .zero
        lastPanOffset = .zero
      } else {
        zoomScale = 3
        lastZoomScale = 3
      }
    }
  }
}
