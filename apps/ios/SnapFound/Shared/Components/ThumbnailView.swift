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

#Preview("No Image") {
  ThumbnailView(data: nil)
    .frame(width: 120, height: 180)
    .clipShape(RoundedRectangle(cornerRadius: 10))
}
