import Foundation
import XCTest
import DankSwiftIRC

class PingMessageTests: XCTestCase {
    func testParsePingMessage() {
        let irc = "PING :tmi.twitch.tv"
        let message = IRCMessage(message: irc).asTwitchMessage()
        switch message {
        case let message as  PingMessage:
            XCTAssertEqual(message.pingPayload, ":tmi.twitch.tv")
        default:
            XCTFail("Expected to be parsed as PING message")
        }
    }
}