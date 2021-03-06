import WebKit

final class WebView: WKWebView {

  fileprivate let initialLocation: BinaryLocation

  init(frame: CGRect, initialLocation: BinaryLocation) {

    self.initialLocation = initialLocation

    super.init(frame: frame, configuration: .init())

    self.navigationDelegate = self

    self.scrollView.delegate = self
    self.scrollView.bounces = false
    self.scrollView.isPagingEnabled = true
    self.scrollView.showsHorizontalScrollIndicator = false
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension WebView: WKNavigationDelegate {

  private func scrollToInitialLocation() {
    switch self.initialLocation {
    case .beginning:
      self.evaluateJavaScript("document.body.scrollLeft = 0", completionHandler: nil)
    case .end:
      self.evaluateJavaScript("document.body.scrollLeft = document.body.scrollWidth", completionHandler: nil)
    }
  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    self.scrollToInitialLocation()
  }

  func webView(
    _ webView: WKWebView,
    decidePolicyFor navigationAction: WKNavigationAction,
    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

    decisionHandler(navigationAction.navigationType == .other ? .allow : .cancel)
  }
}

extension WebView: UIScrollViewDelegate {
  func viewForZooming(in: UIScrollView) -> UIView? {
    return nil
  }
}
