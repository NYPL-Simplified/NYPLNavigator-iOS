import UIKit

public final class DoubleEndedScrollView: UIView {

  public enum Progression {
    case leftToRight
    case rightToLeft
  }

  public let progression: Progression
  public private(set) var viewAtStart: UIView?
  public private(set) var viewAtEnd: UIView?

  public init(frame: CGRect, progression: Progression) {
    self.progression = progression
    super.init(frame: frame)
  }

  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func prependView(_ view: UIView) {

  }

  public func appendView(_ view: UIView) {

  }
}
