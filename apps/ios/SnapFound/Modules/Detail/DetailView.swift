import SwiftData
import SwiftUI

struct DetailView: View {
  let record: ScreenshotRecord

  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss

  @State private var viewModel = DetailViewModel()
  @State private var isSharePresented = false
  @State private var isCopied = false
  @State private var showDeleteConfirmation = false
  @State private var showOpenInPhotosAlert = false

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        screenshotSection
        metadataSection
        ocrSection
        tagsSection
        actionsSection
      }
      .padding(.bottom, 32)
    }
    .navigationTitle("Screenshot")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          isSharePresented = true
        } label: {
          Image(systemName: "square.and.arrow.up")
        }
      }
    }
    .sheet(isPresented: $isSharePresented) {
      ShareSheet(items: viewModel.shareItems(for: record))
    }
    .alert("Open in Photos", isPresented: $showOpenInPhotosAlert) {
      Button("OK", role: .cancel) {}
    } message: {
      Text(
        "Open the Photos app and look for screenshots captured on \(record.creationDate.mediumDisplay)."
      )
    }
    .alert("Delete from Index?", isPresented: $showDeleteConfirmation) {
      Button("Delete", role: .destructive) {
        modelContext.delete(record)
        try? modelContext.save()
        dismiss()
      }
      Button("Cancel", role: .cancel) {}
    } message: {
      Text("The index entry will be removed. Your original photo is not deleted.")
    }
    .task {
      await viewModel.loadImage(for: record)
    }
  }

  // MARK: - Screenshot

  private var screenshotSection: some View {
    Group {
      if let image = viewModel.fullImage {
        Image(uiImage: image)
          .resizable()
          .scaledToFit()
          .frame(maxWidth: .infinity)
          .clipShape(RoundedRectangle(cornerRadius: 16))
          .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
          .padding(.horizontal, 16)
      } else if viewModel.isLoadingImage {
        RoundedRectangle(cornerRadius: 16)
          .fill(.quaternary)
          .aspectRatio(
            CGFloat(record.width) / CGFloat(record.height),
            contentMode: .fit
          )
          .overlay { ProgressView() }
          .padding(.horizontal, 16)
      } else {
        ThumbnailView(data: record.thumbnailData)
          .aspectRatio(
            CGFloat(record.width) / CGFloat(record.height),
            contentMode: .fit
          )
          .clipShape(RoundedRectangle(cornerRadius: 16))
          .padding(.horizontal, 16)
      }
    }
  }

  // MARK: - Metadata

  private var metadataSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      DetailSectionHeader("Info")

      MetadataRow(
        icon: "calendar",
        label: "Captured",
        value: record.creationDate.mediumDisplay
      )
      MetadataRow(
        icon: "ruler",
        label: "Size",
        value: "\(record.width) × \(record.height) px"
      )
    }
    .padding(.horizontal, 16)
  }

  // MARK: - OCR Text

  @ViewBuilder
  private var ocrSection: some View {
    if !record.ocrText.isEmpty {
      VStack(alignment: .leading, spacing: 8) {
        HStack {
          DetailSectionHeader("Extracted Text")
          Spacer()
          copyButton
        }

        Text(record.ocrText)
          .font(.callout)
          .foregroundStyle(.secondary)
          .textSelection(.enabled)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(12)
          .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
      }
      .padding(.horizontal, 16)
    }
  }

  private var copyButton: some View {
    Button {
      UIPasteboard.general.string = record.ocrText
      isCopied = true
      Task {
        try? await Task.sleep(for: .seconds(2))
        isCopied = false
      }
    } label: {
      Label(
        isCopied ? "Copied" : "Copy",
        systemImage: isCopied ? "checkmark" : "doc.on.doc"
      )
      .font(.caption.weight(.medium))
      .foregroundStyle(isCopied ? .green : .primary)
    }
    .animation(.easeInOut(duration: 0.2), value: isCopied)
  }

  // MARK: - Tags

  @ViewBuilder
  private var tagsSection: some View {
    if !record.tags.isEmpty {
      VStack(alignment: .leading, spacing: 8) {
        DetailSectionHeader("Tags")
        FlowLayout(spacing: 6) {
          ForEach(record.tags, id: \.self) { tag in
            TagChip(tag)
          }
        }
      }
      .padding(.horizontal, 16)
    }
  }

  // MARK: - Actions

  private var actionsSection: some View {
    VStack(spacing: 10) {
      // Share
      Button {
        isSharePresented = true
      } label: {
        Label("Share Screenshot", systemImage: "square.and.arrow.up")
          .font(.body.weight(.medium))
          .frame(maxWidth: .infinity)
          .padding(.vertical, 14)
          .background(.tint, in: RoundedRectangle(cornerRadius: 12))
          .foregroundStyle(.white)
      }

      // Open in Photos
      Button {
        if let url = URL(string: "photos-redirect://") {
          UIApplication.shared.open(url) { success in
            if !success { showOpenInPhotosAlert = true }
          }
        } else {
          showOpenInPhotosAlert = true
        }
      } label: {
        Label("View in Photos", systemImage: "photo")
          .font(.body.weight(.medium))
          .frame(maxWidth: .infinity)
          .padding(.vertical, 14)
          .background(.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
          .foregroundStyle(.primary)
      }

      // Delete from index
      Button(role: .destructive) {
        showDeleteConfirmation = true
      } label: {
        Label("Delete from Index", systemImage: "trash")
          .font(.body.weight(.medium))
          .frame(maxWidth: .infinity)
          .padding(.vertical, 14)
          .background(.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
          .foregroundStyle(.red)
      }
    }
    .buttonStyle(.plain)
    .padding(.horizontal, 16)
  }
}

// MARK: - Supporting Views

private struct DetailSectionHeader: View {
  let title: String
  init(_ title: String) { self.title = title }

  var body: some View {
    Text(title)
      .font(.headline)
      .foregroundStyle(.primary)
  }
}

private struct MetadataRow: View {
  let icon: String
  let label: String
  let value: String

  var body: some View {
    Label {
      HStack {
        Text(label).foregroundStyle(.secondary)
        Spacer()
        Text(value).foregroundStyle(.primary)
      }
    } icon: {
      Image(systemName: icon).foregroundStyle(.tint)
    }
    .font(.subheadline)
  }
}

private struct TagChip: View {
  let tag: String
  init(_ tag: String) { self.tag = tag }

  var body: some View {
    Text("#\(tag)")
      .font(.caption.weight(.medium))
      .padding(.horizontal, 10)
      .padding(.vertical, 5)
      .background(.tint.opacity(0.12), in: Capsule())
      .foregroundStyle(.tint)
  }
}

// MARK: - ShareSheet

private struct ShareSheet: UIViewControllerRepresentable {
  let items: [Any]

  func makeUIViewController(context _: Context) -> UIActivityViewController {
    UIActivityViewController(activityItems: items, applicationActivities: nil)
  }

  func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}
