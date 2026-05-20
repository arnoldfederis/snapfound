import SwiftUI

struct ZoomableImageView: View {
  let image: UIImage
  var onSwipeUp: (() -> Void)?

  @State private var scale: CGFloat = 1
  @State private var lastScale: CGFloat = 1
  @State private var offset: CGSize = .zero
  @State private var lastOffset: CGSize = .zero

  var body: some View {
    Image(uiImage: image)
      .resizable()
      .scaledToFit()
      .scaleEffect(scale)
      .offset(offset)
      .gesture(magnifyGesture)
      .simultaneousGesture(dragGesture)
      .onTapGesture(count: 2, perform: doubleTap)
  }

  private var magnifyGesture: some Gesture {
    MagnifyGesture()
      .onChanged { value in
        scale = max(1, lastScale * value.magnification)
      }
      .onEnded { value in
        let newScale = max(1, lastScale * value.magnification)
        withAnimation(.spring(duration: 0.2)) {
          if newScale <= 1 {
            scale = 1
            offset = .zero
            lastOffset = .zero
          } else {
            scale = newScale
          }
        }
        lastScale = scale
      }
  }

  // Uses simultaneousGesture so swipe-up works via onSwipeUp when scale == 1.
  private var dragGesture: some Gesture {
    DragGesture(minimumDistance: 10)
      .onChanged { value in
        guard scale > 1 else { return }
        offset = CGSize(
          width: lastOffset.width + value.translation.width,
          height: lastOffset.height + value.translation.height
        )
      }
      .onEnded { value in
        if scale > 1 {
          lastOffset = offset
        } else if value.translation.height < -50 {
          onSwipeUp?()
        }
      }
  }

  private func doubleTap() {
    withAnimation(.spring(duration: 0.3)) {
      if scale > 1 {
        scale = 1
        lastScale = 1
        offset = .zero
        lastOffset = .zero
      } else {
        scale = 3
        lastScale = 3
      }
    }
  }
}
