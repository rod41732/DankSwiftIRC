//
//  File.swift
//
//
//  Created by road on 2/7/23.
//

import Foundation

// public enum TwitchMessage {
//    // IRC Messages https://dev.twitch.tv/docs/irc
//    case noticeMessage(NoticeMessage)
//    case partMessage([String])
//    case pingMessage(String)
//    case privMessage(PrivMessage)
//
//    case unknownMessgae(IRCMessage)
// }

public extension IRCMessage {
  func asTwitchMessage() -> TwitchMessage {
    switch command {
    case "NOTICE":
      return NoticeMessage(irc: self, timestamp: Int64(tag["rm-received-ts"] ?? ""))
    case "PART":
      return PartMessage(irc: self)
    case "JOIN":
      return JoinMessage(irc: self)
    case "PING":
      return PingMessage(irc: self)
    case "PRIVMSG":
      return PrivMessage(irc: self)
    case "WHISPER":
      return WhisperMessage(irc: self)
    case "CLEARCHAT":
      return ClearChatMessage(irc: self)
    case "GLOBALUSERSTATE":
      return GlobalUserStateMessage(irc: self)
    case "USERNOTICE":
      return UserNoticeMessage(irc: self)
    case "ROOMSTATE":
      return RoomStateMessage(irc: self)
    case "USERSTATE":
      return UserStateMessage(irc: self)

      // TODO: RECONNECT
      // TODO: HOSTTARGET
      // TODO: CLEARMSG

    default:
      return UnknownMessage(irc: self)
    }
  }
}

open class TwitchMessage: Identifiable {
  public var id: String
  public var timestamp: Int64

  public init(id: String, timestamp: Int64) {
    self.id = id
    self.timestamp = timestamp
  }
}

/// AutoIDMessage: generate ID and timestamps at the time it parse, it's not deterministic
/// however it's useful for some type of messages without time information
public class AutoIDMessage: TwitchMessage {
  public var raw: IRCMessage

  init(irc: IRCMessage) {
    raw = irc
    super.init(id: NSUUID().uuidString, timestamp: Int64(Date().timeIntervalSince1970 * 1000))
  }
}

public class UnknownMessage: AutoIDMessage {}
