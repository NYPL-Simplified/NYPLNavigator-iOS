import NYPLNavigator
import UIKit
import WebKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {

    self.window = UIWindow(frame: UIScreen.main.bounds)

    self.window!.rootViewController = NavigatorViewController(spineURLs: AppDelegate.fileURLs(), initialIndex: 0)
    self.window?.makeKeyAndVisible()

    return true
  }

  /// Returns absolute URLs to all files in the OEBPS directory using the order specified by the manifest.
  private class func fileURLs() -> [URL] {
    let stream = InputStream(url: Bundle.main.url(forResource: "manifest", withExtension: "json")!)!
    stream.open()
    defer { stream.close() }
    let object = try! JSONSerialization.jsonObject(with: stream, options: []) as! [String: Any]
    let oebps = object["OEBPS"] as! [String]
    return oebps.map {s in Bundle.main.url(forResource: s, withExtension: nil, subdirectory: "OEBPS")! }
  }
}
