import SwiftUI

struct ThumbnailView: View {
  let data: Data?

  var body: some View {
    if let data, let image = UIImage(data: data) {
      Image(uiImage: image)
        .resizable()
        .scaledToFill()
    } else {
      Rectangle()
        .fill(.quaternary)
        .overlay {
          Image(systemName: "photo")
            .foregroundStyle(.tertiary)
            .font(.title2)
        }
    }
  }
}
