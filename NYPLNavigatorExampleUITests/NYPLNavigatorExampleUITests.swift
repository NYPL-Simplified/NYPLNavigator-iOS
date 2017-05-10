import XCTest

class NYPLNavigatorExampleUITests: XCTestCase {

  override func setUp() {
    super.setUp()
    continueAfterFailure = false
    XCUIApplication().launch()
  }

  func testFoo() {
    XCTAssert(XCUIApplication().windows.element.exists)
  }
}
