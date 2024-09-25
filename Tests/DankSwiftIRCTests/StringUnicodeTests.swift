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


    func testUnicode() {
        var msg = ":🏽" // : followed by skin-tone
        print(msg.prefix(1))
        XCTAssertTrue(msg.firstUnicodeScalar == ":")
        msg.dropFirstUnicodeScalar()
        XCTAssertEqual(msg, "🏽" )

        var msg2 = "foo🏽"
        msg2.dropFirstUnicodeScalar(count: 3)
        XCTAssertEqual(msg2, "🏽" )
    }

    func testActionMessageWithUnicode() {
        let actionMessageSkinTone = "\u{1}ACTION 🏽x\u{1}"
        XCTAssertTrue(actionMessageSkinTone.unicodeSubstring(from: 0, to: 8) == "\u{1}ACTION ")
    }
}