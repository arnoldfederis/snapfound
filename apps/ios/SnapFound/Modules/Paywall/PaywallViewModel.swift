import Foundation
internal import UIKit

@MainActor
@Observable
final class PaywallViewModel {
  private(set) var isLoading = false
  private(set) var errorMessage: String?

  func purchase(using manager: PurchaseManager) async {
    isLoading = true
    errorMessage = nil
    await manager.purchase()
    if case .failed(let err) = manager.purchaseState {
      errorMessage = err.localizedDescription
      Haptics.notification(.error)
    }
    isLoading = false
  }

  func restore(using manager: PurchaseManager) async {
    isLoading = true
    errorMessage = nil
    await manager.restorePurchases()
    if case .failed(let err) = manager.purchaseState {
      errorMessage = err.localizedDescription
      Haptics.notification(.error)
    }
    isLoading = false
  }
}
