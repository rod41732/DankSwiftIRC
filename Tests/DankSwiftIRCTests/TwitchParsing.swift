//
//  File.swift
//  
//
//  Created by road on 2/7/23.
//

import Foundation
import XCTest
import DankSwiftIRC

class TwitchMessageParsingTest: XCTestCase {
    
    func testPartMessageSingleChannel() {
        let irc = ":tmi.twitch.tv PART #pajlada"
        let message = IRCMessage(message: irc).asTwitchMessage()
        if case .partMessage(let channels) = message {
            XCTAssertEqual(channels, ["pajlada"])
        } else {
            XCTFail("Expected to be parsed as PART message")
        }
    }
    
    func testPartMessageMultiChannel() {
        let irc = ":tmi.twitch.tv PART #pajlada,#flex3rs"
        let message = IRCMessage(message: irc).asTwitchMessage()
        if case .partMessage(let channels) = message {
            XCTAssertEqual(channels, ["pajlada", "flex3rs"])
        } else {
            XCTFail("Expected to be parsed as PART message")
        }
    }
    
    func testParsePingMessage() {
        let irc = "PING :tmi.twitch.tv"
        let message = IRCMessage(message: irc).asTwitchMessage()
        if case .pingMessage(let string) = message {
            XCTAssertEqual(string, ":tmi.twitch.tv")
        } else {
            XCTFail("Expected to be parsed as PING message")
        }
    }
    
    
    func testPrivMessageParsing() {
        let irc = "@badge-info=subscriber/2;badges=subscriber/0,no_audio/1;color=#FF69B4;display-name=DOGE41732;emotes=;first-msg=0;flags=;id=224546ee-1715-4d2e-a8f8-53e71e3bb817;mod=0;returning-chatter=0;room-id=11148817;subscriber=1;tmi-sent-ts=1675764985001;turbo=0;user-id=115117172;user-type= :doge41732!doge41732@doge41732.tmi.twitch.tv PRIVMSG #pajlada :-tags FeelsDankMan"
        let message = IRCMessage(message: irc).asTwitchMessage()
        if case .privMessage(let privMessage) = message {
            XCTAssertFalse(privMessage.isAction)
            XCTAssertEqual(privMessage.userColor, "#FF69B4")
            XCTAssertEqual(privMessage.displayName, "DOGE41732")
            XCTAssertEqual(privMessage.emotes.count, 0)
            XCTAssertEqual(privMessage.timestamp, 1675764985001)
            XCTAssertEqual(privMessage.id, "224546ee-1715-4d2e-a8f8-53e71e3bb817")
            XCTAssertEqual(privMessage.channelLogin, "pajlada")
            XCTAssertEqual(privMessage.channelID, "11148817")
            XCTAssertEqual(privMessage.message, "-tags FeelsDankMan")
            XCTAssertEqual(privMessage.isAction, false)
        } else {
            XCTFail("Expected to be parsed as PRIVMSG message")
        }
    }
    
    func testPrivMessageParsingWithSingleWord() {
        let irc = "@badge-info=subscriber/2;badges=subscriber/0,no_audio/1;color=#FF69B4;display-name=DOGE41732;emotes=;first-msg=0;flags=;id=224546ee-1715-4d2e-a8f8-53e71e3bb817;mod=0;returning-chatter=0;room-id=11148817;subscriber=1;tmi-sent-ts=1675764985001;turbo=0;user-id=115117172;user-type= :doge41732!doge41732@doge41732.tmi.twitch.tv PRIVMSG #pajlada FeelsDankMan"
        let message = IRCMessage(message: irc).asTwitchMessage()
        if case .privMessage(let privMessage) = message {
            XCTAssertEqual(privMessage.message, "FeelsDankMan")
        } else {
            XCTFail("Expected to be parsed as PRIVMSG message")
        }
    }
    func testPrivMessageParsingWithEmotes() {
        let irc = "@badge-info=subscriber/2;badges=subscriber/0,no_audio/1;color=#FF69B4;display-name=doge41732;emotes=25:6-10;first-msg=0;flags=;id=32fc38c1-7b2a-49f7-93c8-9498df95e282;mod=0;returning-chatter=0;room-id=11148817;subscriber=1;tmi-sent-ts=1675791338326;turbo=0;user-id=115117172;user-type= :doge41732!doge41732@doge41732.tmi.twitch.tv PRIVMSG #pajlada :-tags Kappa"
        let message = IRCMessage(message: irc).asTwitchMessage()
        if case .privMessage(let privMessage) = message {
            XCTAssertEqual(privMessage.emotes.count, 1)
            let emote = privMessage.emotes[0]
            XCTAssertEqual(emote.name, "Kappa")
            XCTAssertEqual(emote.positions.count, 1)
            let (from, to) = emote.positions[0]
            XCTAssertEqual(from, 6)
            XCTAssertEqual(to, 10)
        } else {
            XCTFail("Expected to be parsed as PRIVMSG message")
        }
    }
    
    func testPrivMessageParsingWithUnicodes() {
        // NOTE the way twitch count characters is same as Swift's unicodeScalars
        // e.g. 🇩🇪 is 2 characters (not 1)
        let irc = "@badge-info=subscriber/2;badges=subscriber/0,no_audio/1;color=#FF69B4;display-name=doge41732;emotes=25:14-18;first-msg=0;flags=;id=0741e707-61c4-4059-9fd8-6085948e5aa4;mod=0;returning-chatter=0;room-id=11148817;subscriber=1;tmi-sent-ts=1675791649786;turbo=0;user-id=115117172;user-type= :doge41732!doge41732@doge41732.tmi.twitch.tv PRIVMSG #pajlada :-tags 🇩🇪 test Kappa"
        let message = IRCMessage(message: irc).asTwitchMessage()
        if case .privMessage(let privMessage) = message {
            XCTAssertEqual(privMessage.emotes.count, 1)
            let emote = privMessage.emotes[0]
            XCTAssertEqual(emote.name, "Kappa")
            XCTAssertEqual(emote.positions.count, 1)
            let (from, to) = emote.positions[0]
            XCTAssertEqual(from, 14)
            XCTAssertEqual(to, 18)
        } else {
            XCTFail("Expected to be parsed as PRIVMSG message")
        }
        
        
    }
    func testPrivMessageWithUnicode2() {
        let irc = "@badge-info=subscriber/2;badges=subscriber/0,no_audio/1;color=#FF69B4;display-name=doge41732;emotes=25:9-13/1902:20-24/305954156:28-35;first-msg=0;flags=;id=ab2212cb-57bb-4d40-87a9-4d2979bf1aab;mod=0;returning-chatter=0;room-id=11148817;subscriber=1;tmi-sent-ts=1675791853779;turbo=0;user-id=115117172;user-type= :doge41732!doge41732@doge41732.tmi.twitch.tv PRIVMSG #pajlada :-tags 🇩🇪 Kappa 🇩🇪 샤 Keepo 보 PogChamp"
        let message = IRCMessage(message: irc).asTwitchMessage()
        if case .privMessage(let privMessage) = message {
            XCTAssertEqual(privMessage.message, "-tags 🇩🇪 Kappa 🇩🇪 샤 Keepo 보 PogChamp")
            XCTAssertEqual(privMessage.emotes.count, 3)
            // NOTE we assume order of emote is related to the input here, it's pretty bad
            XCTAssertEqual(privMessage.emotes[0].name, "Kappa")
            XCTAssertEqual(privMessage.emotes[1].name, "Keepo")
            XCTAssertEqual(privMessage.emotes[2].name, "PogChamp")
        } else {
            XCTFail("Expected to be parsed as PRIVMSG message")
        }
    }
    
    func testPrivMessageParsingWithAction() {
        let irc = "@badge-info=subscriber/2;badges=subscriber/0,no_audio/1;color=#FF69B4;display-name=doge41732;emotes=25:19-23;first-msg=0;flags=;id=7e436bfb-1c06-4d4d-b3fe-e0f594f27cbb;mod=0;returning-chatter=0;room-id=11148817;subscriber=1;tmi-sent-ts=1675792044481;turbo=0;user-id=115117172;user-type= :doge41732!doge41732@doge41732.tmi.twitch.tv PRIVMSG #pajlada :\u{1}ACTION -tags ACTION ZULUL Kappa\u{1}"
        let message = IRCMessage(message: irc).asTwitchMessage()
        if case .privMessage(let privMessage) = message {
            XCTAssertTrue(privMessage.isAction)
            XCTAssertEqual(privMessage.message, "-tags ACTION ZULUL Kappa")
            XCTAssertEqual(privMessage.emotes.count, 1)
            XCTAssertEqual(privMessage.emotes[0].name, "Kappa")
        } else {
            XCTFail("Expected to be parsed as PRIVMSG message")
        }
    }
    
    func testPrivMessageParsingWithActionAndUnicodes() {
        let irc = "@badge-info=subscriber/2;badges=subscriber/0,no_audio/1;color=#FF69B4;display-name=doge41732;emotes=25:9-13/1902:20-24/305954156:28-35;first-msg=0;flags=;id=6c7ca98d-90a7-4d4b-9f40-684cb24df987;mod=0;returning-chatter=0;room-id=11148817;subscriber=1;tmi-sent-ts=1675792229547;turbo=0;user-id=115117172;user-type= :doge41732!doge41732@doge41732.tmi.twitch.tv PRIVMSG #pajlada :\u{1}ACTION -tags 🇩🇪 Kappa 🇩🇪 샤 Keepo 보 PogChamp\u{1}"
        let message = IRCMessage(message: irc).asTwitchMessage()
        if case .privMessage(let privMessage) = message {
            XCTAssertEqual(privMessage.message, "-tags 🇩🇪 Kappa 🇩🇪 샤 Keepo 보 PogChamp")
            XCTAssertEqual(privMessage.emotes.count, 3)
            // NOTE we assume order of emote is related to the input here, it's pretty bad
            XCTAssertEqual(privMessage.emotes[0].name, "Kappa")
            XCTAssertEqual(privMessage.emotes[1].name, "Keepo")
            XCTAssertEqual(privMessage.emotes[2].name, "PogChamp")
        } else {
            XCTFail("Expected to be parsed as PRIVMSG message")
        }
        
    }
    
    
}
