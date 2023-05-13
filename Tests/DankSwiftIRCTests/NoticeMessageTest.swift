import DankSwiftIRC
import Foundation
import XCTest

class NoticeMessageTest: XCTestCase {
  func testParse() {
    let irc = "@msg-id=slow_on :tmi.twitch.tv NOTICE #mm2pl :This room is now in slow mode. You may send messages every 10 seconds."
    let message = IRCMessage(message: irc).asTwitchMessage()
    switch message {
    case let message as NoticeMessage:
      XCTAssertEqual(message.channelLogin, "mm2pl")
      XCTAssertEqual(message.message, "This room is now in slow mode. You may send messages every 10 seconds.")
      XCTAssertEqual(message.messageType, "slow_on")
    default:
      XCTFail("Expected to be parsed as NoticeMessage")
    }
  }
}
