import SwiftUI

struct DestructiveActionModal: View {
  let title: String
  let message: String
  let actionLabel: String
  let action: () -> Void

  @Environment(\.dismiss) private var dismiss

  var body: some View {
    VStack(spacing: 24) {
      Image(systemName: "exclamationmark.triangle.fill")
        .font(.system(size: 44))
        .foregroundStyle(.red)
        .padding(.top, 32)

      VStack(spacing: 8) {
        Text(title)
          .font(.headline)
          .multilineTextAlignment(.center)
        Text(message)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal, 16)
      }

      Spacer()

      VStack(spacing: 12) {
        Button(role: .destructive) {
          action()
          dismiss()
        } label: {
          Text(actionLabel)
            .font(.body.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.red, in: RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(.white)
        }
        .buttonStyle(.plain)

        Button("Cancel") { dismiss() }
          .font(.body)
          .foregroundStyle(.secondary)
          .padding(.bottom, 8)
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 24)
    }
    .presentationDetents([.medium])
  }
}

#Preview {
  DestructiveActionModal(
    title: "Delete all indexed data?",
    message: "This removes all OCR text and tags. Your photos are not affected.",
    actionLabel: "Delete Index"
  ) {}
}
