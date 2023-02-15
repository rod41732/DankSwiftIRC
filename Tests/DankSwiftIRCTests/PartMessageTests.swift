
import Foundation
import XCTest
import DankSwiftIRC

class PartMessageTests: XCTestCase {
    func testPartMessageSingleChannel() {
        let irc = ":tmi.twitch.tv PART #pajlada"
        let message = IRCMessage(message: irc).asTwitchMessage()
        switch message {
        case let message as PartMessage:
            XCTAssertEqual(message.channels, ["pajlada"])
        default:
            XCTFail("Expected to be parsed as PART message")
        }
    }
    
    func testPartMessageMultiChannel() {
        let irc = ":tmi.twitch.tv PART #pajlada,#flex3rs"
        let message = IRCMessage(message: irc).asTwitchMessage()
        switch message {
        case let message as PartMessage:
            XCTAssertEqual(message.channels, ["pajlada", "flex3rs"])
        default:
            XCTFail("Expected to be parsed as PART message")
        }
    }
}