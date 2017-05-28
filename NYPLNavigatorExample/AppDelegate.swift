import NYPLNavigator
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var doubleEndedScrollView = DoubleEndedScrollView(frame: CGRect.zero, progression: .leftToRight)
  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {

    self.window = UIWindow(frame: UIScreen.main.bounds)

    let viewController = UIViewController()
    viewController.view = self.doubleEndedScrollView
    viewController.view.frame = self.window!.bounds

    self.window!.rootViewController = UIViewController()
    self.window?.makeKeyAndVisible()

    return true
  }
}
