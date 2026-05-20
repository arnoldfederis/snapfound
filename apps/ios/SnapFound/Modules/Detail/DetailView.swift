import SwiftData
import SwiftUI

struct DetailView: View {
  let record: ScreenshotRecord

  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss

  @State private var viewModel = DetailViewModel()
  @State private var showInfo = false
  @State private var isSharePresented = false

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()

      if let image = viewModel.fullImage {
        ZoomableImageView(image: image) {
          showInfo = true
          Haptics.impact(.light)
        }
        .ignoresSafeArea()
      } else if viewModel.isLoadingImage {
        ProgressView()
          .tint(.white)
      } else {
        ThumbnailView(data: record.thumbnailData)
          .scaledToFit()
          .ignoresSafeArea()
      }
    }
    .navigationTitle(record.creationDate.shortDisplay)
    .navigationBarTitleDisplayMode(.inline)
    .toolbarColorScheme(.dark, for: .navigationBar, .bottomBar)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          isSharePresented = true
        } label: {
          Image(systemName: "square.and.arrow.up")
        }
      }
      ToolbarItem(placement: .bottomBar) {
        Spacer()
      }
      ToolbarItem(placement: .bottomBar) {
        Button {
          showInfo = true
          Haptics.impact(.light)
        } label: {
          Image(systemName: "info.circle")
        }
      }
    }
    .sheet(isPresented: $showInfo) {
      DetailInfoPanel(record: record, image: viewModel.fullImage) {
        modelContext.delete(record)
        try? modelContext.save()
        dismiss()
      }
    }
    .sheet(isPresented: $isSharePresented) {
      ShareSheet(items: viewModel.shareItems(for: record))
    }
    .task {
      await viewModel.loadImage(for: record)
    }
  }
}

// MARK: - ShareSheet

struct ShareSheet: UIViewControllerRepresentable {
  let items: [Any]

  func makeUIViewController(context _: Context) -> UIActivityViewController {
    UIActivityViewController(activityItems: items, applicationActivities: nil)
  }

  func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}
