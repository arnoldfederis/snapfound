import SwiftData
import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    supportedInterfaceOrientationsFor window: UIWindow?
  ) -> UIInterfaceOrientationMask {
    .portrait
  }
}

@main
struct SnapFoundApp: App {
  // TODO: Add Shortcuts/App Intents support for quickly searching screenshots.
  // TODO: Add duplicate screenshot cleanup, smart folders, and Widgets after the MVP index is stable.
  @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
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
