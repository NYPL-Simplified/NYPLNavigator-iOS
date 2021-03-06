import UIKit
import WebKit

public final class NavigatorViewController: UIViewController {

  private let delegatee: Delegatee!
  public let spineURLs: [URL]
  private let triptychView: TriptychView

  public init(spineURLs: [URL], initialIndex: Int) {
    precondition(initialIndex >= 0)
    precondition(initialIndex < spineURLs.count)

    self.delegatee = Delegatee()
    self.spineURLs = spineURLs
    self.triptychView = TriptychView(frame: CGRect.zero, viewCount: spineURLs.count, initialIndex: initialIndex)

    super.init(nibName: nil, bundle: nil)

    self.delegatee.parent = self

    self.triptychView.delegate = self.delegatee
    self.triptychView.frame = self.view.bounds
    self.triptychView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    self.view.addSubview(self.triptychView)
  }

  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override var prefersStatusBarHidden: Bool {
    return true
  }
}

/// Used to hide conformance to package-private delegate protocols.
private final class Delegatee: NSObject {
  weak var parent: NavigatorViewController!
}

extension Delegatee: TriptychViewDelegate {

  public func triptychView(
    _ view: TriptychView,
    viewForIndex index: Int,
    location: BinaryLocation
  ) -> UIView {

    let url = self.parent.spineURLs[index]

    let webView = WebView(frame: view.bounds, initialLocation: location)
    webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())

    return webView
  }
}
