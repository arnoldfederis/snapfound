import SwiftUI

struct ScreenshotGridCell: View {
  let record: ScreenshotRecord
  var matchedTerms: [String] = []
  var isSelected: Bool = false

  @ViewBuilder
  private var thumbnailContent: some View {
    if record.height > 0 {
      Color.clear
        .frame(maxWidth: .infinity)
        .aspectRatio(9 / 16, contentMode: .fit)
        .clipped()
        .overlay {
          ThumbnailView(data: record.thumbnailData)
            .frame(maxWidth: .infinity)
            .aspectRatio(CGFloat(record.width) / CGFloat(record.height), contentMode: .fit)
            .clipped()
        }
    } else {
      ThumbnailView(data: record.thumbnailData)
        .frame(maxWidth: .infinity)
        .aspectRatio(9 / 16, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
          RoundedRectangle(cornerRadius: 10, style: .continuous)
            .stroke(Color(.separator), lineWidth: 0.5)
        }
    }
  }

  var body: some View {
    VStack(spacing: 0) {
      ZStack(alignment: .topLeading) {
        thumbnailContent

        if isSelected {
          Image(systemName: "checkmark.circle.fill")
            .font(.title3)
            .foregroundStyle(.white, .blue)
            .padding(6)
        }
      }

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
    .shadow(
      color: .black.opacity(isSelected ? 0.04 : 0.08),
      radius: isSelected ? 2 : 4,
      y: isSelected ? 1 : 2
    )
    .overlay {
      RoundedRectangle(cornerRadius: 10)
        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
    }
    .accessibilityLabel("Screenshot from \(record.creationDate.shortDisplay)")
    .accessibilityAddTraits(isSelected ? .isSelected : [])
  }
}
