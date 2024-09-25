import DankSwiftIRC
import XCTest
import Foundation

struct RecentMessages: Codable {
    var error: Optional<String>
    var errorCode: Optional<String>
    var messages: [String]
}


class ProblematicMessageParsingTests: XCTestCase {
    /// "#pajlada 🏽" was not properly split by space if using swift's split(" ")
    func testPajaChat() {
        let problematicString = #"@user-type=;user-id=117691339;room-id=11148817;emotes=;id=5d70c89b-14c7-4978-a002-a079d6a0fa3c :mm2pl!mm2pl@mm2pl.tmi.twitch.tv PRIVMSG #pajlada 🏽"#
        let irc = IRCMessage(message: problematicString)
        let _ = irc.asTwitchMessage()
    }
}