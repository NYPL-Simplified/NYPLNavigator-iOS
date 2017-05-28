import UIKit

protocol SpanningPageViewControllerDelegate: class {

  /**
    When this function is called, the receiver must produce a new view given the
    information provided and then call `handler` with the result.

    - Parameters:
      - controller: The `SpanningPageViewController` instance invoking the
        delegate method.
      - viewForIndex: The index `N` of the view to be created where
        `N >= 0 && N < controller.viewCount`.
      - parameter: The view created must have a height of
        `multipleOfSize.height` and a width of `N * multipleOfSize.width` where
        `N >= 1`.
      - handler: The handler to call with the view once it has been created.
        **The handler must be called exactly once on the main thread**.
        Generally speaking, it is best to call the handler as soon as possible.
  */
  func spanningPageViewController(
    controller: SpanningPageViewController,
    viewForIndex: Int,
    multipleOfSize: CGSize,
    handler: (UIView) -> Void
  )

}

final class SpanningPageViewController: UIViewController {

  /// A representation of a location within a `SpanningPageViewController`.
  struct Location {
    /// A natural number indicating a view index to show or currently being
    /// shown.
    let viewIndex: Int
    /// A natural number indicating the page offset to show or currently being
    /// shown for the view at the given `viewIndex`.
    let pageOffsetWithinView: Int
  }

  fileprivate let scrollView = UIScrollView()

  /// The current location being shown to the user.
  private(set) var location: Location

  /// A natural number indicating the total number of views.
  let viewCount: Int

  /// The view currently being shown to the user.
  private(set) var currentView: UIView?

  /// The view prior to `currentView`. Always `nil` when
  /// `location.viewIndex == 0`.
  private(set) var previousView: UIView?

  /// The view subsequent to `currentView`. Always `nil` when
  /// `location.viewIndex == viewCount - 1`.
  private(set) var nextView: UIView?

  weak var delegate: SpanningPageViewControllerDelegate?

  /**
    - Parameters:
      - viewCount: The fixed number of views the controller will allow the user
        to scroll through.
      - location: The initial location to show to the user where
        `location.viewIndex >= 0 && location.viewIndex < viewCount`.
  */
  init(viewCount: Int, location: Location) {
    self.location = location
    self.viewCount = viewCount
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func update() {
    guard let currentView = self.currentView else {
      // Get the very first view to show to the user.
      self.delegate?.spanningPageViewController(
        controller: self,
        viewForIndex: self.location.viewIndex,
        multipleOfSize: self.view.bounds.size,
        handler: { view in
          assert(self.currentView == nil)
          precondition(view.frame.height == self.view.frame.height)
          precondition(view.frame.width >= self.view.frame.width)
          precondition(view.frame.width.truncatingRemainder(dividingBy: self.view.frame.width) == 0)
          view.frame = view.bounds
          self.scrollView.contentSize = view.bounds.size
          self.scrollView.addSubview(view)
          self.scrollView.setContentOffset(
            CGPoint(x: self.location.pageOffsetWithinView * Int(view.frame.width), y: 0),
            animated: false)
          self.currentView = view
      })
      return
    }

    // TODO
    abort()
  }
}

// MARK: - UIView
extension SpanningPageViewController {

  override func viewDidLoad() {
    self.scrollView.frame = self.view.bounds
    self.view.addSubview(self.scrollView)
  }
}
