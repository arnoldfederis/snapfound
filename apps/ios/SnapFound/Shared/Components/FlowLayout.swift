import SwiftUI

struct FlowLayout: Layout {
  var spacing: CGFloat = 8

  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache _: inout ()
  ) -> CGSize {
    let rows = computeRows(proposal: proposal, subviews: subviews)
    return CGSize(
      width: proposal.width ?? 0,
      height: rows.map(\.height).reduce(0, +) + CGFloat(max(rows.count - 1, 0)) * spacing
    )
  }

  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache _: inout ()
  ) {
    let rows = computeRows(proposal: proposal, subviews: subviews)
    var y = bounds.minY
    for row in rows {
      var x = bounds.minX
      for subview in row.subviews {
        let size = subview.sizeThatFits(.unspecified)
        subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
        x += size.width + spacing
      }
      y += row.height + spacing
    }
  }

  private struct Row {
    var subviews: [LayoutSubview] = []
    var height: CGFloat = 0
  }

  private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
    let maxWidth = proposal.width ?? 0
    var rows: [Row] = []
    var currentRow = Row()
    var currentX: CGFloat = 0

    for subview in subviews {
      let size = subview.sizeThatFits(.unspecified)
      if currentX + size.width > maxWidth, !currentRow.subviews.isEmpty {
        rows.append(currentRow)
        currentRow = Row()
        currentX = 0
      }
      currentRow.subviews.append(subview)
      currentRow.height = max(currentRow.height, size.height)
      currentX += size.width + spacing
    }
    if !currentRow.subviews.isEmpty { rows.append(currentRow) }
    return rows
  }
}
