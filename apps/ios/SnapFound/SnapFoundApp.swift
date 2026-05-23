import SwiftData
import SwiftUI

@main
struct SnapFoundApp: App {
  @State private var purchaseManager = PurchaseManager()

  var sharedModelContainer: ModelContainer = {
    let schema = Schema([ScreenshotRecord.self])
    let config = ModelConfiguration(
      schema: schema,
      isStoredInMemoryOnly: false
    )
    do {
      return try ModelContainer(for: schema, configurations: [config])
    } catch {
      fatalError("ModelContainer creation failed: \(error)")
    }
  }()

  var body: some Scene {
    WindowGroup {
      HomeView().environment(purchaseManager)
    }
    .modelContainer(sharedModelContainer)
  }
}
