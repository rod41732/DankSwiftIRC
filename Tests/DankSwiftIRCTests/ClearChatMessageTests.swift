import XCTest
import DankSwiftIRC

class ClearChatMessageTests: XCTestCase {

  func testPermaBan() {
    let irc = "@room-id=12345678;target-user-id=87654321;tmi-sent-ts=1642715756806 :tmi.twitch.tv CLEARCHAT #dallas :ronni"
    let message = IRCMessage(message: irc).asTwitchMessage()
    switch message {
      case let message as ClearChatMessage:
        XCTAssertEqual(message.channelID, "12345678")
        XCTAssertEqual(message.channelLogin, "dallas")
        XCTAssertEqual(message.targetUserID, "87654321")
        XCTAssertEqual(message.targetUserLogin, "ronni")
        XCTAssertEqual(message.banDuration, nil)
        XCTAssertEqual(message., expression2: Equatable)
        XCTAssertEqual(message.timestamp, 1642715756806)
      default:
        XCTFail("XD")
    }
  }


  func testClearRoom() {
    let irc = "@room-id=12345678;tmi-sent-ts=1642715695392 :tmi.twitch.tv CLEARCHAT #dallas"
    let message = IRCMessage(message: irc).asTwitchMessage()
    switch message {
      case let message as ClearChatMessage:
        XCTAssertEqual(message.channelID, "12345678")
        XCTAssertEqual(message.channelLogin, "dallas")
        XCTAssertEqual(message.targetUserID, nil)
        XCTAssertEqual(message.targetUserLogin, nil)
        XCTAssertEqual(message.banDuration, nil)
        XCTAssertEqual(message.timestamp, 1642715695392)
      default:
        XCTFail("XD")
    }
  }

  func testTimeoutUser() {
    let irc = "@ban-duration=350;room-id=12345678;target-user-id=87654321;tmi-sent-ts=1642719320727 :tmi.twitch.tv CLEARCHAT #dallas :ronni"
    let message = IRCMessage(message: irc).asTwitchMessage()
    switch message {
      case let message as ClearChatMessage:
        XCTAssertEqual(message.channelID, "12345678")
        XCTAssertEqual(message.channelLogin, "dallas")
        XCTAssertEqual(message.targetUserID, "87654321")
        XCTAssertEqual(message.targetUserLogin, "ronni")
        XCTAssertEqual(message.banDuration, 350)
        XCTAssertEqual(message.timestamp, 1642719320727)
      default:
        XCTFail("XD")
    }   
  }



}