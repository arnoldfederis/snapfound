import SwiftUI

struct ThumbnailView: View {
  let data: Data?
  let height: Int
  var contentMode: ContentMode = .fill

  var body: some View {
    if let data, let image = UIImage(data: data) {
      Image(uiImage: image)
        .resizable()
        .aspectRatio(contentMode: height < 2000 ? .fit : .fill)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
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
  ThumbnailView(data: nil, height: 0)
    .frame(width: 120, height: 180)
    .clipShape(RoundedRectangle(cornerRadius: 10))
}
