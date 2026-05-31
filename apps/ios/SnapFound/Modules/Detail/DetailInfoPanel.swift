import SwiftData
import SwiftUI

struct DetailInfoPanel: View {
  let record: ScreenshotRecord
  let image: UIImage?
  let onDelete: () -> Void

  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @State private var isCopied = false
  @State private var isSharePresented = false
  @State private var showPhotosOpenError = false
  @State private var isReindexing = false
  @State private var reindexErrorMessage: String?

  var body: some View {
    NavigationStack {
      List {
        metadataSection
        if !record.ocrText.isEmpty { ocrSection }
        if !record.tags.isEmpty { tagsSection }
        actionsSection
      }
      .navigationTitle("Info")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Done") { dismiss() }
        }
      }
    }
    .sheet(isPresented: $isSharePresented) {
      ShareSheet(items: shareItems).presentationDetents([.medium, .large])
    }
    .alert("Couldn’t Open Photos", isPresented: $showPhotosOpenError) {
      Button("OK", role: .cancel) {}
    } message: {
      Text("Open the Photos app manually and look for this screenshot by its captured date.")
    }
  }

  private var shareItems: [Any] {
    var items: [Any] = []
    if let image { items.append(image) }
    if !record.ocrText.isEmpty { items.append(record.ocrText) }
    return items
  }

  private var metadataSection: some View {
    Section("Info") {
      LabeledContent("Captured", value: record.creationDate.mediumDisplay)
      LabeledContent("Size", value: "\(record.width) × \(record.height) px")
    }
  }

  @ViewBuilder
  private var ocrSection: some View {
    Section {
      HStack(alignment: .top) {
        Text(record.ocrText)
          .font(.callout)
          .foregroundStyle(.secondary)
          .textSelection(.enabled)
        Spacer()
        Button {
          copyExtractedText()
        } label: {
          Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
        }
        .animation(.easeInOut(duration: 0.2), value: isCopied)
      }
    } header: {
      Text("Extracted Text")
    }
  }

  @ViewBuilder
  private var tagsSection: some View {
    Section("Tags") {
      FlowLayout(spacing: 6) {
        ForEach(record.tags, id: \.self) { tag in
          Text("#\(tag)")
            .font(.caption.weight(.medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(.tint.opacity(0.12), in: Capsule())
            .foregroundStyle(.tint)
        }
      }
    }
  }

  private var actionsSection: some View {
    Section {
      if !record.ocrText.isEmpty {
        Button {
          copyExtractedText()
        } label: {
          Label(
            isCopied ? "Copied Text" : "Copy Extracted Text",
            systemImage: isCopied ? "checkmark" : "doc.on.doc"
          )
          .foregroundStyle(.accent)
        }
      }

      Button {
        Haptics.impact(.light)
        isSharePresented = true
      } label: {
        Label("Share Text and Screenshot", systemImage: "square.and.arrow.up")
      }
      .disabled(shareItems.isEmpty)

      Button {
        reindexScreenshot()
      } label: {
        Label(
          isReindexing ? "Re-indexing..." : "Re-index This Screenshot",
          systemImage: "arrow.triangle.2.circlepath"
        )
        .foregroundStyle(.accent)
      }
      .disabled(isReindexing)
    } footer: {
      if let reindexErrorMessage {
        Text(reindexErrorMessage)
          .foregroundStyle(.red)
      }
    }
  }

  private func copyExtractedText() {
    guard !record.ocrText.isEmpty else { return }
    UIPasteboard.general.string = record.ocrText
    isCopied = true
    Haptics.notification(.success)
    Task {
      try? await Task.sleep(for: .seconds(2))
      isCopied = false
    }
  }

  private func reindexScreenshot() {
    isReindexing = true
    reindexErrorMessage = nil
    Task {
      defer { isReindexing = false }
      do {
        try await IndexingService.shared.reindex(record: record, modelContext: modelContext)
        Haptics.notification(.success)
      } catch {
        reindexErrorMessage = error.localizedDescription
        Haptics.notification(.error)
      }
    }
  }
}
private struct ShareSheet: UIViewControllerRepresentable {
  let items: [Any]

  func makeUIViewController(context: Context) -> UIActivityViewController {
    UIActivityViewController(activityItems: items, applicationActivities: nil)
  }

  func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
  let record = ScreenshotRecord(
    assetID: "preview-1",
    creationDate: .now,
    ocrText:
      "Order confirmation #12345\nYour order has been placed successfully.\nEstimated delivery: 3-5 business days.",
    tags: ["order", "confirmation", "shopping"],
    width: 390,
    height: 844,
    thumbnailData: nil
  )
  DetailInfoPanel(record: record, image: nil, onDelete: {})
    .modelContainer(for: ScreenshotRecord.self, inMemory: true)
}
