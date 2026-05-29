import StoreKit
import SwiftUI

struct PaywallView: View {
  @Environment(PurchaseManager.self) private var purchaseManager
  @Environment(\.dismiss) private var dismiss

  @State private var viewModel = PaywallViewModel()

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
    .onChange(of: purchaseManager.isPro) {
      if purchaseManager.isPro {
        Haptics.notification(.success)
        dismiss()
      }
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

      Text("Search every screenshot,\nnot just the first 50.")
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
        subtitle: "Index your entire screenshot library - no cap"
      )
      FeatureRow(
        icon: "lock.shield.fill",
        title: "Private On-Device OCR",
        subtitle: "All processing stays on your device. No cloud."
      )
      FeatureRow(
        icon: "magnifyingglass",
        title: "Natural Language Search",
        subtitle: "Find screenshots by what's in them"
      )
      FeatureRow(
        icon: "arrow.triangle.2.circlepath",
        title: "One-Time Purchase",
        subtitle: "Pay once, own forever. No subscription."
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
        Task { await viewModel.purchase(using: purchaseManager) }
      } label: {
        HStack {
          if viewModel.isLoading {
            ProgressView().tint(.white)
          } else {
            Text("Unlock Lifetime Access")
              .font(.body.weight(.semibold))
          }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.tint, in: RoundedRectangle(cornerRadius: 14))
        .foregroundStyle(.white)
      }
      .disabled(viewModel.isLoading || purchaseManager.product == nil)

      Button {
        Haptics.selection()
        Task { await viewModel.restore(using: purchaseManager) }
      } label: {
        Text("Restore Purchase")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
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
        "Check your internet connection or try again later. Your purchase is safe — it's a one-time payment with no subscription."
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
      Text("SnapFound never uploads your screenshots. No accounts, no servers, no tracking.")
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
