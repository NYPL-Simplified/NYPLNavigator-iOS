import UIKit

protocol TriptychViewDelegate: class {

  func triptychView(
    _ view: TriptychView,
    viewForIndex index: Int,
    location: BinaryLocation)
    -> UIView
}

final class TriptychView: UIView {

  fileprivate enum Clamping {
    case none
    case onlyPrevious
    case onlyNext
  }

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

  fileprivate var clamping: Clamping = .none

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
    self.scrollView.contentOffset.x = size.width * CGFloat(offset)
  }

  fileprivate func updateViews(previousIndex: Int? = nil) {

    if previousIndex == self.index {
      return
    }

    guard let delegate = self.delegate else {
      return
    }

    func viewForIndex(_ index: Int, location: BinaryLocation) -> UIView {
      guard let views = self.views, let previousIndex = previousIndex else {
        return delegate.triptychView(self, viewForIndex: index, location: location)
      }

      var indexesToCurrentViews: [Int: UIView] = [:]

      switch views {
      case .one(let view):
        indexesToCurrentViews[0] = view
      case .two(let firstView, let secondView):
        indexesToCurrentViews[0] = firstView
        indexesToCurrentViews[1] = secondView
      case .many(let currentView, let otherViews):
        indexesToCurrentViews[previousIndex] = currentView
        switch otherViews {
        case .first(let view):
          indexesToCurrentViews[previousIndex - 1] = view
        case .second(let view):
          indexesToCurrentViews[previousIndex + 1] = view
        case .both(let firstView, let secondView):
          indexesToCurrentViews[previousIndex - 1] = firstView
          indexesToCurrentViews[previousIndex + 1] = secondView
        }
      }

      if let view = indexesToCurrentViews[index] {
        return view
      }

      return delegate.triptychView(self, viewForIndex: index, location: location)
    }

    switch self.viewCount {
    case 1:
      assert(self.index == 0)
      let view = viewForIndex(0, location: .beginning)
      self.views = Views.one(view: view)
    case 2:
      assert(self.index < 2)
      if index == 0 {
        let firstView = viewForIndex(0, location: .beginning)
        let secondView = viewForIndex(1, location: .beginning)
        self.views = Views.two(firstView: firstView, secondView: secondView)
      } else {
        let firstView = viewForIndex(0, location: .end)
        let secondView = viewForIndex(1, location: .beginning)
        self.views = Views.two(firstView: firstView, secondView: secondView)
      }
    default:
      let currentView = viewForIndex(self.index, location: .beginning)
      if self.index == 0 {
        self.views = Views.many(
          currentView: currentView,
          otherViews: Disjunction.second(value:
            viewForIndex(self.index + 1, location: .beginning)))
      } else if self.index == self.viewCount - 1 {
        self.views = Views.many(
          currentView: currentView,
          otherViews: Disjunction.first(value:
            viewForIndex(self.index - 1, location: .end)))
      } else {
        self.views = Views.many(
          currentView: currentView,
          otherViews: Disjunction.both(
            first: viewForIndex(self.index - 1, location: .end),
            second: viewForIndex(self.index + 1, location: .beginning)))
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

    if views.count == 3 {
      let width = self.frame.size.width
      let xOffset = self.scrollView.contentOffset.x

      switch self.clamping {
      case .none:
        if xOffset < width {
          self.clamping = .onlyPrevious
        } else if xOffset > width {
          self.clamping = .onlyNext
        }
      case .onlyPrevious:
        self.scrollView.contentOffset.x = min(xOffset, width)
      case .onlyNext:
        self.scrollView.contentOffset.x = max(xOffset, width)
      }
    }
  }

  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

    self.clamping = .none

    let previousIndex = self.index

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

    self.updateViews(previousIndex: previousIndex)

    // This works around a very specific case that may be a bug in iOS's scroll
    // view implementation. If the user is on a view of index >= 1, and if the
    // user swipes forward slightly and then, with great force, swipes back and
    // quickly lets go, the scroll view will slam up against the clamped
    // boundary and "bounce" even if bouncing is disabled. The reason for this
    // is unclear! In any case, the following code compensates for this by
    // animating a transition to a content offset on a page boundary if, for any
    // reason (including the above), the scroll view has come rest on an offset
    // that is _not_ a page boundary. The conditional guard here prevents
    // animating if the offset is already correct because otherwise doing so may
    // result in a visual glitch (also for unknown reasons).
    if(fmod(scrollView.contentOffset.x, self.scrollView.frame.width) != 0.0) {
      self.scrollView.setContentOffset(
        .init(x: CGFloat(pageOffset) * self.scrollView.frame.width, y: 0),
        animated: true)
    }
  }
}
