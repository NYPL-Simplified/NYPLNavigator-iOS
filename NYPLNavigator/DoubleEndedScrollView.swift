import UIKit

public final class DoubleEndedScrollView: UIView {

  public enum Progression {
    case leftToRight
    case rightToLeft
  }

  public let progression: Progression
  public private(set) var viewAtStart: UIView?
  public private(set) var viewAtEnd: UIView?
  private let scrollView = UIScrollView()

  public init(frame: CGRect, progression: Progression) {
    self.progression = progression

    super.init(frame: frame)

    self.scrollView.frame = self.bounds
    self.scrollView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
  }

  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public var frame: CGRect {
    get {
      return super.frame
    }
    set {

    }
  }

  /// Appends a view to the current start of the scrollview (i.e. left of
  public func prependViewToStart(_ view: UIView) {

  }

  public func appendViewAtEnd(_ view: UIView) {

  }

  public func removeViewAtStart() {

  }

  public func removeViewAtEnd() {

  }
}
