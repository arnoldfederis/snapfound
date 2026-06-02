import StoreKit
import SwiftUI

struct PaywallView: View {
  @Environment(PurchaseManager.self) private var purchaseManager
  @Environment(\.dismiss) private var dismiss

  let onIndexNow: (@MainActor () -> Void)?

  @State private var viewModel = PaywallViewModel()
  @State private var showPurchaseConfirmation = false

  init(onIndexNow: (@MainActor () -> Void)? = nil) {
    self.onIndexNow = onIndexNow
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 32) {
          heroSection
          featuresSection
          pricingSection
          privacyNote
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
        .padding(.bottom, 48)
      }
      .navigationTitle("")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Close") { dismiss() }
        }
      }
    }
    .onAppear {
      if purchaseManager.isPro { dismiss() }
    }
    .alert("Purchase Complete", isPresented: $showPurchaseConfirmation) {
      Button("Index Now") {
        Haptics.notification(.success)
        onIndexNow?()
        dismiss()
      }
      .tint(.accentColor)

      Button("Not now", role: .cancel) {
        dismiss()
      }
    } message: {
      Text("SnapFound Pro is unlocked. Index your screenshots now?")
    }
  }

  // MARK: - Hero

  private var heroSection: some View {
    VStack(spacing: 12) {
      Image(systemName: "sparkle.magnifyingglass")
        .font(.system(size: 60))
        .foregroundStyle(.tint)
        .symbolRenderingMode(.hierarchical)

      Text("SnapFound Pro")
        .font(.largeTitle.bold())

      Text("Search beyond the first 50 screenshots.")
        .font(.title3)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }
  }

  // MARK: - Features

  private var featuresSection: some View {
    VStack(spacing: 0) {
      FeatureRow(
        icon: "photo.stack.fill",
        title: "Unlimited Screenshot Indexing",
        subtitle: "Index all screenshots you allow SnapFound to access"
      )
      FeatureRow(
        icon: "lock.shield.fill",
        title: "Private On-Device OCR",
        subtitle: "Text recognition happens on your iPhone"
      )
      FeatureRow(
        icon: "magnifyingglass",
        title: "Fast Screenshot Search",
        subtitle: "Find screenshots by the text inside them"
      )
      FeatureRow(
        icon: "arrow.triangle.2.circlepath",
        title: "One-Time Purchase",
        subtitle: "One-time unlock. No subscription."
      )
    }
  }

  // MARK: - Pricing

  private var pricingSection: some View {
    VStack(spacing: 12) {
      if let product = purchaseManager.product {
        Text(product.displayPrice)
          .font(.system(size: 44, weight: .bold, design: .rounded))
        Text("One-time purchase · No subscription")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      } else {
        productUnavailableNote
      }

      Button {
        Haptics.impact(.medium)
        Task {
          if await viewModel.purchase(using: purchaseManager) {
            showPurchaseConfirmation = true
          }
        }
      } label: {
        HStack {
          if viewModel.isLoading {
            ProgressView().tint(.white)
          } else {
            Text("Unlock Pro")
              .font(.body.weight(.semibold))
          }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.tint, in: RoundedRectangle(cornerRadius: 14))
        .foregroundStyle(.white)
      }
      .tint(.accentColor)
      .disabled(viewModel.isLoading || purchaseManager.product == nil)

      Button {
        Haptics.selection()
        Task {
          if await viewModel.restore(using: purchaseManager) {
            Haptics.notification(.success)
            dismiss()
          }
        }
      } label: {
        Text("Restore Purchase")
          .font(.subheadline)
      }
      .tint(.accentColor)
      .disabled(viewModel.isLoading)

      if let error = viewModel.errorMessage {
        Text(error)
          .font(.caption)
          .foregroundStyle(.red)
          .multilineTextAlignment(.center)
      }
    }
  }

  // MARK: - Product Unavailable

  private var productUnavailableNote: some View {
    VStack(spacing: 8) {
      Image(systemName: "wifi.exclamationmark")
        .font(.title2)
        .foregroundStyle(.secondary)
      Text("Price unavailable")
        .font(.subheadline.weight(.medium))
        .foregroundStyle(.secondary)
      Text(
        "Check your internet connection or try again later. SnapFound Pro is a one-time purchase with no subscription."
      )
      .font(.caption)
      .foregroundStyle(.secondary)
      .multilineTextAlignment(.center)
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(.background)
  }

  // MARK: - Privacy Note

  private var privacyNote: some View {
    Label {
      Text("SnapFound never uploads your screenshots. No account, no tracking, no cloud upload.")
        .font(.caption)
        .foregroundStyle(.secondary)
    } icon: {
      Image(systemName: "lock.shield")
        .foregroundStyle(.green)
        .font(.caption)
    }
    .multilineTextAlignment(.center)
    .frame(maxWidth: .infinity)
  }
}

// MARK: - Feature Row

private struct FeatureRow: View {
  let icon: String
  let title: String
  let subtitle: String

  var body: some View {
    HStack(spacing: 14) {
      Image(systemName: icon)
        .font(.title2)
        .foregroundStyle(.tint)
        .frame(width: 36)

      VStack(alignment: .leading, spacing: 2) {
        Text(title).font(.subheadline.weight(.semibold))
        Text(subtitle).font(.caption).foregroundStyle(.secondary)
      }

      Spacer()
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 14)
  }
}

#Preview {
  PaywallView()
    .environment(PurchaseManager())
}
