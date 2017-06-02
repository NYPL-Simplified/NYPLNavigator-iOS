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

    let viewController = TriptychViewController(viewCount: 6, initialIndex: 5)
    viewController.delegate = self

    self.window!.rootViewController = viewController
    self.window?.makeKeyAndVisible()

    return true
  }
}

extension AppDelegate: TriptychViewControllerDelegate {

  func triptychViewController(
    _ viewController: TriptychViewController,
    viewForIndex index: Int,
    location: TriptychViewController.Location
  ) -> UIView {

    let view = UIView()
    switch index {
    case 0:
      view.backgroundColor = UIColor.red
    case 1:
      view.backgroundColor = UIColor.orange
    case 2:
      view.backgroundColor = UIColor.yellow
    case 3:
      view.backgroundColor = UIColor.green
    case 4:
      view.backgroundColor = UIColor.blue
    case 5:
      view.backgroundColor = UIColor.purple
    default:
      fatalError()
    }

    return view
  }
}
