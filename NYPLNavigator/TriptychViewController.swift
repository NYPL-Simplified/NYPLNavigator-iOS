import UIKit

public protocol TriptychViewControllerDelegate: class {

  func triptychViewController(
    _ viewController: TriptychViewController,
    viewForIndex index: Int,
    location: TriptychViewController.Location)
    -> UIView
}

public class TriptychViewController: UIViewController {

  public enum Location {
    case start
    case end
  }

  private enum Views {
    case one(view: UIView)
    case two(firstView: UIView, secondView: UIView)
    case many(currentView: UIView, otherViews: Disjunction<UIView, UIView>)

    var array: [UIView] {
      switch self {
      case .one(let view):
        return [view]
      case .two(let firstView, let secondView):
        return [firstView, secondView]
      case .many(let currentView, let otherViews):
        switch otherViews {
        case .first(let previousView):
          return [previousView, currentView]
        case .second(let nextView):
          return [currentView, nextView]
        case .both(let previousView, let nextView):
          return [previousView, currentView, nextView]
        }
      }
    }

    var count: Int {
      switch self {
      case .one:
        return 1
      case .two:
        return 2
      case .many(_, let otherViews):
        return 1 + otherViews.count
      }
    }
  }

  public weak var delegate: TriptychViewControllerDelegate?

  private(set) var index: Int

  private let scrollView: UIScrollView

  public let viewCount: Int

  private var views: Views?

  private var isAtAnEdge: Bool {
    return self.index == 0 || self.index == self.viewCount - 1
  }

  public init(viewCount: Int, initialIndex: Int) {
    precondition(viewCount >= 1)
    precondition(initialIndex >= 0 && initialIndex < viewCount)

    self.index = initialIndex
    self.scrollView = UIScrollView()
    self.viewCount = viewCount
    super.init(nibName: nil, bundle: nil)
    self.scrollView.delegate = self
  }

  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func viewDidLoad() {
    self.scrollView.frame = self.view.bounds
    self.scrollView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    self.scrollView.isPagingEnabled = true
    self.view.addSubview(self.scrollView)
  }

  public override func viewWillLayoutSubviews() {
    guard let views = self.views else {
      self.scrollView.contentSize = self.view.bounds.size
      return
    }

    let size = self.view.frame.size

    self.scrollView.contentSize = CGSize(width: size.width * CGFloat(views.count), height: size.height)

    if let viewArray = self.views?.array {
      for (index, view) in viewArray.enumerated() {
        view.frame = CGRect(origin: CGPoint(x: size.width * CGFloat(index), y: 0), size: size)
      }
    }

    let offset = min(1, self.index)
    self.scrollView.setContentOffset(CGPoint(x: size.width * CGFloat(offset), y: 0), animated: false)
  }

  public override func viewWillAppear(_ animated: Bool) {
    if self.views != nil {
      // We already set up our initial state.
      return
    }

    guard let delegate = self.delegate else {
      return
    }

    switch self.viewCount {
    case 1:
      assert(self.index == 0)
      let view = delegate.triptychViewController(self, viewForIndex: 0, location: .start)
      self.views = Views.one(view: view)
    case 2:
      assert(self.index < 2)
      if index == 0 {
        let firstView = delegate.triptychViewController(self, viewForIndex: 0, location: .start)
        let secondView = delegate.triptychViewController(self, viewForIndex: 1, location: .start)
        self.views = Views.two(firstView: firstView, secondView: secondView)
      } else {
        let firstView = delegate.triptychViewController(self, viewForIndex: 0, location: .end)
        let secondView = delegate.triptychViewController(self, viewForIndex: 1, location: .start)
        self.views = Views.two(firstView: firstView, secondView: secondView)
      }
    default:
      let currentView = delegate.triptychViewController(self, viewForIndex: self.index, location: .start)
      if self.index == 0 {
        self.views = Views.many(
          currentView: currentView,
          otherViews: Disjunction.second(value:
            delegate.triptychViewController(self, viewForIndex: self.index + 1, location: .start)))
      } else if self.index == self.viewCount - 1 {
        self.views = Views.many(
          currentView: currentView,
          otherViews: Disjunction.first(value:
            delegate.triptychViewController(self, viewForIndex: self.index - 1, location: .end)))
      } else {
        self.views = Views.many(
          currentView: currentView,
          otherViews: Disjunction.both(
            first: delegate.triptychViewController(self, viewForIndex: self.index - 1, location: .end),
            second: delegate.triptychViewController(self, viewForIndex: self.index + 1, location: .start)))
      }
    }

    self.syncSubviews()
    self.view.setNeedsLayout()
  }

  private func syncSubviews() {
    for view in self.scrollView.subviews {
      view.removeFromSuperview()
    }

    if let viewArray = self.views?.array {
      for view in viewArray {
        self.scrollView.addSubview(view)
      }
    }
  }

  private func moveToIndex(_ nextIndex: Int) {
    if self.index == nextIndex {
      return
    }
  }
}

extension TriptychViewController: UIScrollViewDelegate {

}
