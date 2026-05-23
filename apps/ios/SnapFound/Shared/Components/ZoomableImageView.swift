import SwiftUI

struct ZoomableImageView: View {
  let image: UIImage
  var onSwipeUp: (() -> Void)?
  var onDismiss: (() -> Void)?
  var onDismissProgress: ((Double) -> Void)?
  var onSingleTap: (() -> Void)?

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
      .simultaneousGesture(zoomedPanGesture)
      .overlay {
        // UIKit overlay handles taps and vertical-only pan so horizontal swipes
        // reach the TabView's UIPageViewController gesture recognizer.
        PhotoGestureOverlay(
          zoomScale: zoomScale,
          onSingleTap: { onSingleTap?() },
          onDoubleTap: doubleTap,
          onVerticalChanged: { dy in
            if dy > 0 {
              dismissOffset = dy
              onDismissProgress?(dismissProgress)
            }
          },
          onVerticalEnded: { dy, vy in
            if dy < -50 {
              onSwipeUp?()
              resetDismiss()
            } else if dy > 100 || vy > 500 {
              onDismiss?()
            } else {
              resetDismiss()
            }
          }
        )
      }
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

  // MARK: - Pinch to zoom / pinch-to-dismiss

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

  // MARK: - Pan when zoomed in (SwiftUI drag, only active at zoom > 1)

  private var zoomedPanGesture: some Gesture {
    DragGesture(minimumDistance: 10)
      .onChanged { value in
        guard zoomScale > 1 else { return }
        panOffset = CGSize(
          width: lastPanOffset.width + value.translation.width,
          height: lastPanOffset.height + value.translation.height
        )
      }
      .onEnded { _ in
        guard zoomScale > 1 else { return }
        lastPanOffset = panOffset
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

// MARK: - UIKit gesture overlay

/// Handles single/double tap and vertical-only pan via UIKit recognizers.
/// `gestureRecognizerShouldBegin` returns false for horizontal pans at 1x zoom,
/// letting the TabView's UIPageViewController recognizer take over.
private struct PhotoGestureOverlay: UIViewRepresentable {
  let zoomScale: CGFloat
  let onSingleTap: () -> Void
  let onDoubleTap: () -> Void
  let onVerticalChanged: (CGFloat) -> Void
  let onVerticalEnded: (CGFloat, CGFloat) -> Void

  func makeUIView(context: Context) -> UIView {
    let view = UIView()
    view.backgroundColor = .clear

    let doubleTap = UITapGestureRecognizer(
      target: context.coordinator,
      action: #selector(Coordinator.handleDouble)
    )
    doubleTap.numberOfTapsRequired = 2

    let singleTap = UITapGestureRecognizer(
      target: context.coordinator,
      action: #selector(Coordinator.handleSingle)
    )
    singleTap.numberOfTapsRequired = 1
    singleTap.require(toFail: doubleTap)

    let pan = UIPanGestureRecognizer(
      target: context.coordinator,
      action: #selector(Coordinator.handlePan)
    )
    pan.delegate = context.coordinator

    view.addGestureRecognizer(doubleTap)
    view.addGestureRecognizer(singleTap)
    view.addGestureRecognizer(pan)
    return view
  }

  func updateUIView(_ uiView: UIView, context: Context) {
    context.coordinator.currentZoomScale = zoomScale
    context.coordinator.onSingleTap = onSingleTap
    context.coordinator.onDoubleTap = onDoubleTap
    context.coordinator.onVerticalChanged = onVerticalChanged
    context.coordinator.onVerticalEnded = onVerticalEnded
  }

  func makeCoordinator() -> Coordinator { Coordinator() }

  final class Coordinator: NSObject, UIGestureRecognizerDelegate {
    var currentZoomScale: CGFloat = 1
    var onSingleTap: (() -> Void)?
    var onDoubleTap: (() -> Void)?
    var onVerticalChanged: ((CGFloat) -> Void)?
    var onVerticalEnded: ((CGFloat, CGFloat) -> Void)?

    func gestureRecognizerShouldBegin(_ gr: UIGestureRecognizer) -> Bool {
      guard let pan = gr as? UIPanGestureRecognizer else { return true }
      // Zoomed: disable so SwiftUI zoomedPanGesture handles panning
      if currentZoomScale > 1 { return false }
      // At 1x: only start for predominantly vertical movement
      let v = pan.velocity(in: pan.view)
      return abs(v.y) > abs(v.x)
    }

    func gestureRecognizer(
      _ gr: UIGestureRecognizer,
      shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
    ) -> Bool { true }

    @objc func handleSingle() { onSingleTap?() }
    @objc func handleDouble() { onDoubleTap?() }

    @objc func handlePan(_ pan: UIPanGestureRecognizer) {
      let t = pan.translation(in: pan.view)
      let v = pan.velocity(in: pan.view)
      switch pan.state {
      case .changed: onVerticalChanged?(t.y)
      case .ended, .cancelled: onVerticalEnded?(t.y, v.y)
      default: break
      }
    }
  }
}
