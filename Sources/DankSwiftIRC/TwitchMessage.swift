//
//  File.swift
//  
//
//  Created by road on 2/7/23.
//

import Foundation

public enum TwitchMessage {
    // IRC Messages https://dev.twitch.tv/docs/irc
    case noticeMessage(NoticeMessage)
    case partMessage([String])
    case pingMessage(String)
    case privMessage(PrivMessage)
    
    case unknownMessgae(IRCMessage)
}

public extension IRCMessage {
    func asTwitchMessage() -> TwitchMessage {
        switch command {
        case "NOTICE":
            return .noticeMessage(NoticeMessage(irc: self))
        case "PART":
            let channelsPart = params.components(separatedBy: " ").first!
            let channels = channelsPart.components(separatedBy: ",").map { String($0.dropFirst(1)) }
            return .partMessage(channels)
        case "PING":
            return .pingMessage(params)
        case "PRIVMSG":
            return .privMessage(PrivMessage(irc: self))
            
        default:
            return .unknownMessgae(self)
        }
        
    }
}

public struct NoticeMessage {
    init(irc: IRCMessage) { }
}

public struct TwitchIRCEmote {
//    public static func == (lhs: TwitchIRCEmote, rhs: TwitchIRCEmote) -> Bool {
//        return lhs.emoteID == rhs.emoteID &&
//        lhs.name == rhs.name &&
//        lhs.positions == rhs.positions
//    }
    
    public var emoteID: String
    public var name: String
    public var positions: [(Int, Int)]
}

func parseEmotes(raw: String, message: String) -> [TwitchIRCEmote] {
    return raw.components(separatedBy: "/").compactMap { part in
        if part.isEmpty { return nil }
        return parseEmote(part, message: message)
    }
}

extension String {
    func unicodeSubstring(from: Int, to: Int) -> String {
        let u = unicodeScalars
        let fromIndex = u.index(u.startIndex, offsetBy: from)
        let toIndex = u.index(u.startIndex, offsetBy: to)
        return String(u[fromIndex ..< toIndex])
    }
}

public func parseEmote(_ part: String, message: String) -> TwitchIRCEmote {
    // 100000:1-2,3-4
    let parts = part.components(separatedBy: ":")
    let emoteID = parts[0]
    let positions = parts[1].components(separatedBy: ",").map { range in
        let nums = range.components(separatedBy: "-")
        return (Int(nums[0])!, Int(nums[1])!)
    }
    let (from, to) = positions[0]
    let name = message.unicodeSubstring(from: from, to: to + 1) // twitch indexing is inclusive end
    return TwitchIRCEmote(emoteID: emoteID, name: String(name), positions: positions)
}

public struct PrivMessage {
    public var userColor: String // color in hex like #aabbcc, or empty if user haven't set any color
    public var userLogin: String
    public var displayName: String
    public var emotes: [TwitchIRCEmote]
    public var timestamp: Int // ms since epoch
    public var id: String
    
    public var channelLogin: String
    public var channelID: String
    
    public var message: String
    public var isAction: Bool // is /me message
    
    public var raw: IRCMessage
    
    public init(irc: IRCMessage) {
        raw = irc
        
        userColor = irc.tag["color"] ?? ""
        userLogin = String(irc.prefix[..<irc.prefix.firstIndex(of: "!")!])
        displayName = irc.tag["display-name"] ?? userLogin
        timestamp = Int(irc.tag["tmi-sent-ts"]!)!
        channelID = irc.tag["room-id"]!
        id = irc.tag["id"]!
        
        let parts = irc.params.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
        let channelPart = parts[0]
        let messagePart = parts[1]
        
        channelLogin = String(channelPart.dropFirst(1))
        
        //
        let rawMessage = messagePart.first == ":" ? messagePart.dropFirst(1) : messagePart
        isAction = rawMessage.prefix(8) == "\u{1}ACTION "
        message = String(isAction ? rawMessage.dropFirst(8).dropLast(1) : rawMessage)
        
        emotes = parseEmotes(raw: irc.tag["emotes"] ?? "", message: message)
    }
}

