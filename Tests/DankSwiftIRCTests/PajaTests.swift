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
        let problematicString = #"@first-msg=0;mod=0;color=#DAA520;turbo=0;subscriber=1;rm-received-ts=1721598869229;badge-info=subscriber/37;tmi-sent-ts=1721598869047;user-type=;user-id=117691339;room-id=11148817;flags=;display-name=Mm2PL;returning-chatter=0;historical=1;badges=subscriber/36,glitchcon2020/1;emotes=;id=5d70c89b-14c7-4978-a002-a079d6a0fa3c :mm2pl!mm2pl@mm2pl.tmi.twitch.tv PRIVMSG #pajlada 🏽"#
        let irc = IRCMessage(message: problematicString)
        let _ = irc.asTwitchMessage()
    }
}