import DankSwiftIRC
import Foundation
import XCTest

class JoinMessageTests: XCTestCase {
  func testPartMessageSingleChannel() {
    let irc = ":tmi.twitch.tv JOIN #pajlada"
    let message = IRCMessage(message: irc).asTwitchMessage()
    switch message {
    case let message as JoinMessage:
      XCTAssertEqual(message.channels, ["pajlada"])
    default:
      XCTFail("Expected to be parsed as JOIN message")
    }
  }

  func testPartMessageMultiChannel() {
    let irc = ":tmi.twitch.tv JOIN #pajlada,#flex3rs"
    let message = IRCMessage(message: irc).asTwitchMessage()
    switch message {
    case let message as JoinMessage:
      XCTAssertEqual(message.channels, ["pajlada", "flex3rs"])
    default:
      XCTFail("Expected to be parsed as JOIN message")
    }
  }
}
