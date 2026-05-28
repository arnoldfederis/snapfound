import SwiftData
import SwiftUI

struct ScreenshotGridCell: View {
  let record: ScreenshotRecord
  var matchedTerms: [String] = []
  var isSelected: Bool = false

  private let gridCornerRadius: CGFloat = 10

  private var visibleMatchedTerms: [String] {
    var seen: Set<String> = []
    return matchedTerms.compactMap { term in
      let normalized =
        term
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .lowercased()
      guard !normalized.isEmpty, seen.insert(normalized).inserted else { return nil }
      return normalized
    }
  }

  private var thumbnailContent: some View {
    Color.clear
      .aspectRatio(9.0 / 16.0, contentMode: .fit)
      .overlay {
        ThumbnailView(data: record.thumbnailData, height: record.height)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
  }

  var body: some View {
    VStack(spacing: 0) {
      ZStack(alignment: .topLeading) {
        thumbnailContent
          .clipShape(RoundedRectangle(cornerRadius: gridCornerRadius, style: .continuous))

        if isSelected {
          Image(systemName: "checkmark.circle.fill")
            .font(.title3)
            .foregroundStyle(.white, Color.accentColor)
            .padding(6)
        }
      }
      .background()
      .clipShape(RoundedRectangle(cornerRadius: gridCornerRadius, style: .continuous))
      .shadow(
        color: .black.opacity(isSelected ? 0.0 : 0.06),
        radius: 2,
        y: 1
      )
      .overlay {
        RoundedRectangle(cornerRadius: gridCornerRadius, style: .continuous)
          .strokeBorder(
            isSelected ? Color.accentColor : Color(.separator),
            lineWidth: isSelected ? 3 : 0.5
          )
      }

      Group {
        if !visibleMatchedTerms.isEmpty {
          HStack(spacing: 3) {
            ForEach(visibleMatchedTerms.prefix(2), id: \.self) { term in
              Text(term)
                .font(.system(size: 9, weight: .medium))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(Color.accentColor.opacity(0.15), in: Capsule())
                .foregroundStyle(Color.accentColor)
            }
          }
          .padding(.horizontal, 6)
        } else {
          Text(record.creationDate.relativeDisplay)
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
      }
      .padding(.vertical, 8)
    }
    .accessibilityLabel("Screenshot from \(record.creationDate.shortDisplay)")
    .accessibilityAddTraits(isSelected ? .isSelected : [])
  }
}

#Preview {
  let record = ScreenshotRecord(
    assetID: "preview-1",
    creationDate: .now,
    ocrText: "Wi-Fi password: hello123",
    tags: ["wifi", "password"],
    width: 390,
    height: 844,
    thumbnailData: nil
  )
  HStack(spacing: 12) {
    ScreenshotGridCell(record: record, matchedTerms: ["wifi"])
      .frame(width: 130)
    ScreenshotGridCell(record: record, isSelected: true)
      .frame(width: 130)
  }
  .padding()
  .modelContainer(for: ScreenshotRecord.self, inMemory: true)
}
