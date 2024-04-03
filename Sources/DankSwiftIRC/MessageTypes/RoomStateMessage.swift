import Foundation

public class RoomStateMessage: TwitchMessage {
  public var emoteOnly: Bool?
  // minutes,
  // -1 if disabled (no follow required)
  // 0 if follower can immediately chat
  // otherwise, the number of minutes to wait before chatting
  public var followersOnly: Int?
  public var r9kMode: Bool? // aka unique message mode
  public var slowModeDelay: Int? // 0 if disabled
  public var subsOnly: Bool?
  /// whether rituals, e.g. new user, is enabled
  public var rituals: Bool?

  public var channelID: String
  public var channelLogin: String

  public var raw: IRCMessage

  public init(irc: IRCMessage) {
    raw = irc

    channelID = irc.tag["room-id"]!
    channelLogin = String(irc.params.dropFirst(1)) // #pajlada -> pajlada

    if let emoteOnlyTag = irc.tag["emote-only"] {
      emoteOnly = emoteOnlyTag == "1"
    }
    if let followerOnlyTag = irc.tag["followers-only"] {
      followersOnly = Int(followerOnlyTag)
    }
    if let r9kTag = irc.tag["r9k"] {
      r9kMode = r9kTag == "1"
    }
    if let slowModeTag = irc.tag["slow"] {
      slowModeDelay = Int(slowModeTag)
    }
    if let subsOnlyTag = irc.tag["subs-only"] {
      subsOnly = subsOnlyTag == "1"
    }
    if let ritualsTag = irc.tag["rituals"] {
      rituals = ritualsTag == "1"
    }

    super.init(id: NSUUID().uuidString, timestamp: Int64(
      Date().timeIntervalSince1970 * 1000
    ))
  }

  override public func rawIRC() -> IRCMessage {
    return raw
  }
}
