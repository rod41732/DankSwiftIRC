import DankSwiftIRC
import Foundation
import XCTest

class UserStateMessageTest: XCTestCase {
  func testUserStateFromPrivMsg() {
    let irc = "@badge-info=;badges=broadcaster/1,no_audio/1;client-nonce=forsen;color=#FF69B4;display-name=doge41732;emote-sets=0,33563,771852,1511989,300374282,592920959;id=fed0095b-b0c3-43af-b4db-c93def42c3f1;mod=0;subscriber=0;user-type= :tmi.twitch.tv USERSTATE #doge41732"
    let message = IRCMessage(message: irc).asTwitchMessage()
    switch message {
    case let message as UserStateMessage:
      XCTAssertEqual(message.channelLogin, "doge41732")
      XCTAssertEqual(message.emoteSets, ["0", "33563", "771852", "1511989", "300374282", "592920959"])
      XCTAssertEqual(message.clientNonce, "forsen")
    default:
      XCTFail("Expected to be parsed as UserStateMessage")
    }
  }

  func testRoomStateDiff() {
    let irc = "@badge-info=;badges=no_audio/1;color=#FF69B4;display-name=doge41732;emote-sets=0,33563,771852,1511989,300374282,592920959,e21484e8-cf11-48b1-8b67-c180fa39f926;mod=0;subscriber=0;user-type= :tmi.twitch.tv USERSTATE #pajlada"
    let message = IRCMessage(message: irc).asTwitchMessage()
    switch message {
    case let message as UserStateMessage:
      XCTAssertEqual(message.channelLogin, "pajlada")
      XCTAssertEqual(message.emoteSets, ["0", "33563", "771852", "1511989", "300374282", "592920959", "e21484e8-cf11-48b1-8b67-c180fa39f926"])

    default:
      XCTFail("Expected to be parsed as UserStateMessage")
    }
  }
}
