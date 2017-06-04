import UIKit

protocol TriptychViewDelegate: class {

  func triptychView(
    _ view: TriptychView,
    viewForIndex index: Int,
    location: BinaryLocation)
    -> UIView
}

final class TriptychView: UIView {

  fileprivate enum Views {
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

  public weak var delegate: TriptychViewDelegate? {
    didSet {
      self.updateViews()
    }
  }

  fileprivate(set) var index: Int

  fileprivate let scrollView: UIScrollView

  public let viewCount: Int

  fileprivate var views: Views?

  // FIXME: Hack?
  var isLimitingForwardScroll = false

  private var isAtAnEdge: Bool {
    return self.index == 0 || self.index == self.viewCount - 1
  }

  public init(frame: CGRect, viewCount: Int, initialIndex: Int) {

    precondition(viewCount >= 1)
    precondition(initialIndex >= 0 && initialIndex < viewCount)

    self.index = initialIndex
    self.scrollView = UIScrollView()
    self.viewCount = viewCount

    super.init(frame: frame)

    self.scrollView.delegate = self
    self.scrollView.frame = self.bounds
    self.scrollView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    self.scrollView.isPagingEnabled = true
    self.scrollView.bounces = false
    self.addSubview(self.scrollView)
  }

  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func layoutSubviews() {

    if self.views == nil {
      self.updateViews()
    }

    guard let views = self.views else {
      self.scrollView.contentSize = self.bounds.size
      return
    }

    let size = self.frame.size

    self.scrollView.contentSize = CGSize(width: size.width * CGFloat(views.count), height: size.height)

    if let viewArray = self.views?.array {
      for (index, view) in viewArray.enumerated() {
        view.frame = CGRect(origin: CGPoint(x: size.width * CGFloat(index), y: 0), size: size)
      }
    }

    let offset = min(1, self.index)
    self.scrollView.setContentOffset(CGPoint(x: size.width * CGFloat(offset), y: 0), animated: false)
  }

  fileprivate func updateViews() {
    guard let delegate = self.delegate else {
      return
    }

    switch self.viewCount {
    case 1:
      assert(self.index == 0)
      let view = delegate.triptychView(self, viewForIndex: 0, location: .beginning)
      self.views = Views.one(view: view)
    case 2:
      assert(self.index < 2)
      if index == 0 {
        let firstView = delegate.triptychView(self, viewForIndex: 0, location: .beginning)
        let secondView = delegate.triptychView(self, viewForIndex: 1, location: .beginning)
        self.views = Views.two(firstView: firstView, secondView: secondView)
      } else {
        let firstView = delegate.triptychView(self, viewForIndex: 0, location: .end)
        let secondView = delegate.triptychView(self, viewForIndex: 1, location: .beginning)
        self.views = Views.two(firstView: firstView, secondView: secondView)
      }
    default:
      let currentView = delegate.triptychView(self, viewForIndex: self.index, location: .beginning)
      if self.index == 0 {
        self.views = Views.many(
          currentView: currentView,
          otherViews: Disjunction.second(value:
            delegate.triptychView(self, viewForIndex: self.index + 1, location: .beginning)))
      } else if self.index == self.viewCount - 1 {
        self.views = Views.many(
          currentView: currentView,
          otherViews: Disjunction.first(value:
            delegate.triptychView(self, viewForIndex: self.index - 1, location: .end)))
      } else {
        self.views = Views.many(
          currentView: currentView,
          otherViews: Disjunction.both(
            first: delegate.triptychView(self, viewForIndex: self.index - 1, location: .end),
            second: delegate.triptychView(self, viewForIndex: self.index + 1, location: .beginning)))
      }
    }

    self.syncSubviews()
    self.setNeedsLayout()
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

extension TriptychView: UIScrollViewDelegate {

  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard let views = self.views else {
      return
    }

    if scrollView.contentOffset.x < self.scrollView.frame.width
      && views.count == 3 {

      // We're scrolling back, so let's lock the view so we can't scroll
      // forwards and skip the next chapter. It'll get reset later.
      let size = self.frame.size
      scrollView.contentSize = CGSize(width: size.width * 2.0, height: size.height)
      self.isLimitingForwardScroll = true
    }
  }

  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

    if self.isLimitingForwardScroll {
      let size = self.frame.size
      scrollView.contentSize = CGSize(width: size.width * 3.0, height: size.height)
      self.isLimitingForwardScroll = false
    }

    let pageOffset = Int(round(scrollView.contentOffset.x / self.scrollView.frame.width))
    if pageOffset == 0 {
      if self.index > 0 {
        self.index -= 1
      }
    } else if pageOffset == 1 {
      if self.index == 0 {
        self.index += 1
      }
    } else {
      assert(pageOffset == 2)
      self.index += 1
    }

    self.updateViews()
  }
}
