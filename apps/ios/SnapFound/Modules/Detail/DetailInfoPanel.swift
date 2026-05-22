import SwiftUI

struct DetailInfoPanel: View {
  let record: ScreenshotRecord
  let image: UIImage?
  let onDelete: () -> Void

  @Environment(\.dismiss) private var dismiss
  @State private var isCopied = false
  @State private var isSharePresented = false
  @State private var showDeleteModal = false

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
      ShareSheet(items: shareItems)
    }
    .sheet(isPresented: $showDeleteModal) {
      DestructiveActionModal(
        title: "Delete from Index?",
        message: "The index entry will be removed. Your original photo is not deleted.",
        actionLabel: "Delete from Index"
      ) {
        onDelete()
        dismiss()
      }
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
          UIPasteboard.general.string = record.ocrText
          isCopied = true
          Task {
            try? await Task.sleep(for: .seconds(2))
            isCopied = false
          }
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
      Button {
        isSharePresented = true
      } label: {
        Label("Share Screenshot", systemImage: "square.and.arrow.up")
      }
      Button(role: .destructive) {
        Haptics.notification(.warning)
        showDeleteModal = true
      } label: {
        Label("Delete from Index", systemImage: "trash")
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

