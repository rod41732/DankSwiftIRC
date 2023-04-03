import DankSwiftIRC
import XCTest

class TestUnescape: XCTestCase {
  func testUnescapeNonEscaped() {
    let escaped = "FeelsDankMan"
    XCTAssertEqual(unescape(escaped), "FeelsDankMan")
  }

  func testTrailingBackslashIsDropped() {
    let escaped = "FeelsDankMan\\"
    XCTAssertEqual(unescape(escaped), "FeelsDankMan")
  }

  func testEscapeSequence() {
    let escaped = "FeelsDankMan\\sAnotherWord\\n\\r\\:\\\\"
    XCTAssertEqual(unescape(escaped), "FeelsDankMan AnotherWord\n\r;\\")
  }

  func testInvalidEscapeSequence() {
    let escaped = "\\FeelsDankMan"
    XCTAssertEqual(unescape(escaped), "FeelsDankMan")
  }
}
