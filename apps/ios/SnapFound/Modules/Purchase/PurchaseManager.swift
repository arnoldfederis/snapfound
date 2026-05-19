import StoreKit

@MainActor
@Observable
final class PurchaseManager {
  // Keep this product ID if already created in App Store Connect.
  static let productID = "app.snapfound.SnapFound.lifetime"

  private(set) var isPro: Bool = false
  private(set) var purchaseState: PurchaseState = .notPurchased
  private(set) var product: Product?

  // @ObservationIgnored + nonisolated(unsafe): excluded from tracking so deinit
  // can cancel without a MainActor hop; Task<Void,Never> is Sendable so this is safe.
  @ObservationIgnored nonisolated(unsafe) private var transactionListener: Task<Void, Never>?

  init() {
    transactionListener = listenForTransactions()
    Task {
      await loadProduct()
      await checkEntitlements()
    }
  }

  deinit {
    transactionListener?.cancel()
  }

  // MARK: - Public

  func purchase() async {
    guard let product else {
      purchaseState = .failed(PurchaseError.productNotFound)
      return
    }
    purchaseState = .purchasing
    do {
      let result = try await product.purchase()
      switch result {
      case .success(let verification):
        let transaction = try verified(verification)
        await transaction.finish()
        isPro = true
        purchaseState = .purchased
      case .userCancelled:
        purchaseState = .notPurchased
      case .pending:
        purchaseState = .pending
      @unknown default:
        purchaseState = .notPurchased
      }
    } catch {
      purchaseState = .failed(error)
    }
  }

  func restorePurchases() async {
    do {
      try await AppStore.sync()
      await checkEntitlements()
    } catch {
      purchaseState = .failed(error)
    }
  }

  // MARK: - Private

  private func loadProduct() async {
    do {
      let products = try await Product.products(for: [Self.productID])
      product = products.first
    } catch {
      #if DEBUG
        print("[PurchaseManager] product fetch failed: \(error)")
      #endif
    }
  }

  private func checkEntitlements() async {
    for await result in Transaction.currentEntitlements {
      guard case .verified(let transaction) = result,
        transaction.productID == Self.productID,
        transaction.revocationDate == nil
      else { continue }
      isPro = true
      purchaseState = .purchased
      return
    }
  }

  private func listenForTransactions() -> Task<Void, Never> {
    Task(priority: .background) {
      for await result in Transaction.updates {
        guard case .verified(let transaction) = result else { continue }
        if transaction.productID == Self.productID {
          self.isPro = true
          self.purchaseState = .purchased
        }
        await transaction.finish()
      }
    }
  }

  private func verified<T>(_ result: VerificationResult<T>) throws -> T {
    switch result {
    case .unverified: throw PurchaseError.failedVerification
    case .verified(let value): return value
    }
  }
}
