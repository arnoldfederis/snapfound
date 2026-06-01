import Foundation
internal import UIKit

@MainActor
@Observable
final class PaywallViewModel {
  private(set) var isLoading = false
  private(set) var errorMessage: String?

  func purchase(using manager: PurchaseManager) async -> Bool {
    isLoading = true
    errorMessage = nil
    await manager.purchase()
    defer { isLoading = false }

    if case .purchased = manager.purchaseState {
      return true
    }

    if case .failed(let err) = manager.purchaseState {
      errorMessage = err.localizedDescription
      Haptics.notification(.error)
    }
    return false
  }

  func restore(using manager: PurchaseManager) async -> Bool {
    isLoading = true
    errorMessage = nil
    await manager.restorePurchases()
    defer { isLoading = false }

    if manager.isPro {
      return true
    }

    if case .failed(let err) = manager.purchaseState {
      errorMessage = err.localizedDescription
      Haptics.notification(.error)
    }
    return false
  }
}
