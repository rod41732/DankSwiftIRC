import DankSwiftIRC
import Foundation
import XCTest

class RoomStateMessageTest: XCTestCase {
  func testInitialRoomState() {
    let irc = "@emote-only=0;followers-only=-1;r9k=0;rituals=0;room-id=11148817;slow=0;subs-only=0 :tmi.twitch.tv ROOMSTATE #pajlada"
    let message = IRCMessage(message: irc).asTwitchMessage()
    switch message {
    case let message as RoomStateMessage:
      XCTAssertEqual(message.channelID, "11148817")
      XCTAssertEqual(message.channelLogin, "pajlada")
      XCTAssertEqual(message.emoteOnly, false)
      XCTAssertEqual(message.followersOnly, -1)
      XCTAssertEqual(message.r9kMode, false)
      XCTAssertEqual(message.rituals, false)
      XCTAssertEqual(message.slowModeDelay, 0)
      XCTAssertEqual(message.subsOnly, false)
    default:
      XCTFail("Expected to be parsed as RoomStateMessage")
    }
  }

  func testRoomStateDiff() {
    let irc = "@slow=10;room-id=123 :tmi.twitch.tv ROOMSTATE #dallas"
    let message = IRCMessage(message: irc).asTwitchMessage()
    switch message {
    case let message as RoomStateMessage:
      XCTAssertEqual(message.channelID, "123")
      XCTAssertEqual(message.channelLogin, "dallas")
      XCTAssertEqual(message.emoteOnly, nil)
      XCTAssertEqual(message.followersOnly, nil)
      XCTAssertEqual(message.r9kMode, nil)
      XCTAssertEqual(message.rituals, nil)
      XCTAssertEqual(message.slowModeDelay, 10)
      XCTAssertEqual(message.subsOnly, nil)
    default:
      XCTFail("Expected to be parsed as RoomStateMessage")
    }
  }
}
