import XCTest 
import DankSwiftIRC 

class StringSplitTests: XCTestCase {
    func  testSplitUnicodeSkinTone() {
        let msg = "#pajlada 🏽"
        let parts = msg.split(byUnicodeScalar: " ")
        print(parts)
        XCTAssertEqual(parts.count, 2, "Should split into 2 parts")
        XCTAssertEqual(parts, ["#pajlada", "\u{0001F3FD}"])
    }   
    
    func testMaxSplits() {
        let msg = "foo bar baz"
        let parts1 = msg.split(byUnicodeScalar: " ", maxSplits: 1)
        XCTAssertEqual(parts1, ["foo", "bar baz"])
        let parts2 = msg.split(byUnicodeScalar: " ", maxSplits: 2)
        XCTAssertEqual(parts2, ["foo", "bar", "baz"])
        let parts3 = msg.split(byUnicodeScalar: " ", maxSplits: 3)
        XCTAssertEqual(parts3, ["foo", "bar", "baz"])
    }

    func testMaxSplitEndWithSep() {
        let msg = "foo bar "
        let parts1 = msg.split(byUnicodeScalar: " ", maxSplits: 1)
        XCTAssertEqual(parts1, ["foo", "bar "])
        let parts2 = msg.split(byUnicodeScalar: " ", maxSplits: 2)
        XCTAssertEqual(parts2, ["foo", "bar", ""])
        let parts3 = msg.split(byUnicodeScalar: " ", maxSplits: 3)
        XCTAssertEqual(parts3, ["foo", "bar", ""])
    }

    func testMaxSplitStartWithSep() {
        let msg = " foo bar"
        let parts1 = msg.split(byUnicodeScalar: " ", maxSplits: 1)
        XCTAssertEqual(parts1, ["", "foo bar"])
        let parts2 = msg.split(byUnicodeScalar: " ", maxSplits: 2)
        XCTAssertEqual(parts2, ["", "foo", "bar"])
        let parts3 = msg.split(byUnicodeScalar: " ", maxSplits: 3)
        XCTAssertEqual(parts3, ["", "foo", "bar"])
    }

}