import NYPLNavigator
import UIKit
import WebKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var doubleEndedScrollView = DoubleEndedScrollView(frame: CGRect.zero, progression: .leftToRight)
  var window: UIWindow?
  let urls = AppDelegate.fileURLs()

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {

    self.window = UIWindow(frame: UIScreen.main.bounds)

    let viewController = TriptychViewController(viewCount: urls.count, initialIndex: 0)
    viewController.delegate = self

    self.window!.rootViewController = viewController
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

extension AppDelegate: TriptychViewControllerDelegate {

  func triptychViewController(
    _ viewController: TriptychViewController,
    viewForIndex index: Int,
    location: TriptychViewController.Location
  ) -> UIView {

    let url = self.urls[index]

    let webView = WKWebView(frame: viewController.view.bounds)
    webView.navigationDelegate = self
    webView.scrollView.bounces = false
    webView.scrollView.isPagingEnabled = true
    webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())

    return webView
  }
}

extension AppDelegate: WKNavigationDelegate {

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
  }
}
