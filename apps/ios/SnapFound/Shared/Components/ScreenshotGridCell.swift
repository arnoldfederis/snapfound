import SwiftUI

struct ScreenshotGridCell: View {
  let record: ScreenshotRecord
  var matchedTerms: [String] = []

  var body: some View {
    VStack(spacing: 0) {
      ThumbnailView(data: record.thumbnailData)
        .frame(maxWidth: .infinity)
        .aspectRatio(9 / 19.5, contentMode: .fill)
        .clipped()

      if !matchedTerms.isEmpty {
        HStack(spacing: 3) {
          ForEach(matchedTerms.prefix(2), id: \.self) { term in
            Text(term)
              .font(.system(size: 9, weight: .medium))
              .padding(.horizontal, 5)
              .padding(.vertical, 2)
              .background(.tint.opacity(0.15), in: Capsule())
              .foregroundStyle(.tint)
          }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
      } else {
        Text(record.creationDate.relativeDisplay)
          .font(.caption2)
          .foregroundStyle(.secondary)
          .padding(4)
      }
    }
    .background(.background)
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
  }
}
