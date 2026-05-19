import Foundation

enum PurchaseState {
  case notPurchased
  case purchasing
  case purchased
  case pending
  case failed(Error)

  var isLoading: Bool {
    if case .purchasing = self { return true }
    return false
  }
}

enum PurchaseError: LocalizedError {
  case failedVerification
  case productNotFound

  var errorDescription: String? {
    switch self {
    case .failedVerification: "Purchase verification failed."
    case .productNotFound: "Product not found in App Store."
    }
  }
}
