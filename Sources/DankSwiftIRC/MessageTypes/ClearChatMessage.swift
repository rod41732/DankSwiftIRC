import Foundation

extension TwitchMessage {
  var this: TwitchMessage { return self }
}

public class ClearChatMessage: TwitchMessage {
  public var banDuration: Int? // seconds, nil if perma

  public var channelID: String
  public var channelLogin: String

  public var targetUserID: String?
  public var targetUserLogin: String?

  public var isClearRoom: Bool {
    return targetUserID == nil
  }

  public var isPermaBan: Bool {
    return targetUserID != nil && banDuration == nil
  }

  public var raw: IRCMessage

  init(irc: IRCMessage) {
    raw = irc

    banDuration = Int(irc.tag["ban-duration"] ?? "")
    channelID = irc.tag["room-id"]!
    targetUserID = irc.tag["target-user-id"]

    let parts = irc.params.split(byUnicodeScalar: " ", maxSplits: 1)
    channelLogin = String(parts[0].dropFirst(1)) // remove the # prefix before channel
    if parts.count == 2 {
      var targetUserLogin = parts[1]
      if targetUserLogin.firstUnicodeScalar == ":" {
        targetUserLogin.dropFirstUnicodeScalar()
      }
    }

    // deterministic ID generation
    // NOTE: twitch usually send multiple CLEARCHAT message, generating ID like this mean that there can be
    // multiple message with same ID
    let ts = irc.tag["tmi-sent-ts"] ?? ""
    let id = "\(ts)-clearchat-\(channelLogin)-\(targetUserLogin ?? "#\(channelLogin)")"
    super.init(id: id, timestamp: Int64(irc.tag["tmi-sent-ts"]!)!)
  }

  override public func rawIRC() -> IRCMessage {
    return raw
  }
}
