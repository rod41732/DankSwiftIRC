import DankSwiftIRC
import XCTest

class MyFirstTest: XCTestCase {
  func testAdd() {
    let input = 1 + 1
    let output = 2
    XCTAssertEqual(input, output, "1 + 1 should equal to 2")
  }
}

class TestIRCParsing: XCTestCase {
  func testParsing1() {
    let irc = ":tmi.twitch.tv 001 doge41732 :Welcome, GLHF!"
    let parsed = IRCMessage(message: irc)
    XCTAssertEqual(parsed.tag, [:])
    XCTAssertEqual(parsed.prefix, "tmi.twitch.tv")
    XCTAssertEqual(parsed.command, "001")
    XCTAssertEqual(parsed.params, "doge41732 :Welcome, GLHF!")
  }

  func testParsingMessageWithTagAndPrefix() {
    let irc = "@foo=1;bar=2 :my.prefix command arg1 arg2"
    let parsed = IRCMessage(message: irc)
    XCTAssertEqual(parsed.tag, [
      "foo": "1",
      "bar": "2"
    ])
    XCTAssertEqual(parsed.prefix, "my.prefix")
    XCTAssertEqual(parsed.command, "command")
    XCTAssertEqual(parsed.params, "arg1 arg2")
  }

  func testMessageWithTagOnly() {
    let irc = "@foo=1;bar=2 command arg1 arg2"
    // let irc = "@foo=1;bar=2 :my.prefix command arg1 arg2"
    let parsed = IRCMessage(message: irc)
    XCTAssertEqual(parsed.tag, [
      "foo": "1",
      "bar": "2"
    ])
    XCTAssertEqual(parsed.prefix, "") // absence is represented as empty
    XCTAssertEqual(parsed.command, "command")
    XCTAssertEqual(parsed.params, "arg1 arg2")
  }

  func testMessageWithPrefixOnly() {
    let irc = ":my.prefix command arg1 arg2"
    let parsed = IRCMessage(message: irc)
    XCTAssertEqual(parsed.tag, [:])
    XCTAssertEqual(parsed.prefix, "my.prefix") // absence is represented as empty
    XCTAssertEqual(parsed.command, "command")
    XCTAssertEqual(parsed.params, "arg1 arg2")
  }

  func testPlainMessage() {
    let irc = "command arg1 arg2"
    let parsed = IRCMessage(message: irc)
    XCTAssertEqual(parsed.tag, [:])
    XCTAssertEqual(parsed.prefix, "") // absence is represented as empty
    XCTAssertEqual(parsed.command, "command")
    XCTAssertEqual(parsed.params, "arg1 arg2")
  }

  func testMessageWithoutArgs() {
    let irc = "command"
    let parsed = IRCMessage(message: irc)
    XCTAssertEqual(parsed.tag, [:])
    XCTAssertEqual(parsed.prefix, "") // absence is represented as empty
    XCTAssertEqual(parsed.command, "command")
    XCTAssertEqual(parsed.params, "")
  }


}