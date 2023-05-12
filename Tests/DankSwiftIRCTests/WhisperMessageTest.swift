import DankSwiftIRC
import XCTest

class WhisperMessageTest: XCTestCase {
  func testParsingWhisper() {
    let irc = "@badges=;color=#2E8B57;display-name=PAJBOT;emotes=;message-id=50;thread-id=82008718_115117172;turbo=0;user-id=82008718;user-type= :pajbot!pajbot@pajbot.tmi.twitch.tv WHISPER doge41732 :Invalid point amount (examples: 100, 10k, 1m, 0.5k)"
    let message = IRCMessage(message: irc).asTwitchMessage()
    switch message {
    case let message as WhisperMessage:
      XCTAssertEqual(message.senderLogin, "pajbot")
      XCTAssertEqual(message.senderDisplayName, "PAJBOT")
      XCTAssertEqual(message.senderID, "82008718")
      XCTAssertEqual(message.senderColor, "#2E8B57")
      XCTAssertEqual(message.receiverLogin, "doge41732")
      XCTAssertEqual(message.id, "50")
      XCTAssertEqual(message.receiverID, "115117172")

    default:
      XCTFail("Expected to be parsed as PART message")
    }
  }

  func testParsingMessageWithEmotes() {
    let irc = "@badges=game-developer/1;color=#F1C40F;display-name=SunRed_;emotes=emotesv2_cb1306b84ade423ea57f89e3ac7db6f6:0-9/1512058:11-17;message-id=4;thread-id=99308836_115117172;turbo=0;user-id=99308836;user-type= :sunred_!sunred_@sunred_.tmi.twitch.tv WHISPER doge41732 :sunredWave pajaHey"
    let message = IRCMessage(message: irc).asTwitchMessage()
    switch message {
    case let message as WhisperMessage:
      XCTAssertEqual(message.senderLogin, "sunred_")
      XCTAssertEqual(message.senderDisplayName, "SunRed_")
      XCTAssertEqual(message.senderID, "99308836")
      XCTAssertEqual(message.senderColor, "#F1C40F")
      XCTAssertEqual(message.receiverLogin, "doge41732")
      XCTAssertEqual(message.id, "4")
      XCTAssertEqual(message.receiverID, "115117172")
      XCTAssertEqual(message.emotes, [
        PrivMessageEmote(emoteID: "emotesv2_cb1306b84ade423ea57f89e3ac7db6f6", name: "sunredWave", position: (0, 9)),
        PrivMessageEmote(emoteID: "1512058", name: "pajaHey", position: (11, 17)),
      ])

    default:
      XCTFail("Expected to be parsed as PART message")
    }
  }
}
