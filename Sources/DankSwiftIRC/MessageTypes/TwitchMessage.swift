//
//  File.swift
//  
//
//  Created by road on 2/7/23.
//

import Foundation



//public enum TwitchMessage {
//    // IRC Messages https://dev.twitch.tv/docs/irc
//    case noticeMessage(NoticeMessage)
//    case partMessage([String])
//    case pingMessage(String)
//    case privMessage(PrivMessage)
//
//    case unknownMessgae(IRCMessage)
//}

public extension IRCMessage {
    func asTwitchMessage() -> TwitchMessage {
        switch command {
        case "NOTICE":
            return NoticeMessage(irc: self)
        case "PART":
            return PartMessage(irc: self)
        case "PING":
            return PingMessage(irc: self)
        case "PRIVMSG":
            return PrivMessage(irc: self)
        case "CLEARCHAT":
            return ClearChatMessage(irc: self)
        default:
            return UnknownMessage(irc: self)
        }
        
    }
}

public class TwitchMessage: Identifiable {
    public var id: String
    public var timestamp: Int64

    init(id: String, timestamp: Int64) {
        self.id = id
        self.timestamp = timestamp
    }
}

public class AutoIDMessage: TwitchMessage {
    public var raw: IRCMessage

    init(irc: IRCMessage) {
        self.raw = irc
        super.init(id: NSUUID().uuidString, timestamp: Int64(Date().timeIntervalSince1970 * 1000))
    }
}
public class NoticeMessage: AutoIDMessage {
    override init(irc: IRCMessage) {
        super.init(irc: irc)
    }
}

public class UnknownMessage: AutoIDMessage {}

