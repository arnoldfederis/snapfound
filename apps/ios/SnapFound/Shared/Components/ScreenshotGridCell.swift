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
      Color.clear
        .frame(maxWidth: .infinity)
        .aspectRatio(9 / 16, contentMode: .fit)
        .overlay {
          ThumbnailView(data: record.thumbnailData)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
        }
    }
  }

  var body: some View {
    VStack(spacing: 0) {
      ZStack(alignment: .topLeading) {
        thumbnailContent
          .padding(.top, 16)
          .clipShape(RoundedRectangle(cornerRadius: gridCornerRadius, style: .continuous))

        if isSelected {
          Image(systemName: "checkmark.circle.fill")
            .font(.title3)
            .foregroundStyle(.white, .blue)
            .padding(6)
        }
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
                .background(Color(.secondarySystemFill), in: Capsule())
                .foregroundStyle(.primary)
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
    .background(.background)
    .clipShape(RoundedRectangle(cornerRadius: gridCornerRadius))
    .shadow(
      color: .black.opacity(isSelected ? 0.04 : 0.08),
      radius: isSelected ? 2 : 4,
      y: isSelected ? 1 : 2
    )
    .overlay {
      RoundedRectangle(cornerRadius: gridCornerRadius)
        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
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
