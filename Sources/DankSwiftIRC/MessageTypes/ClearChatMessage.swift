import Foundation

extension TwitchMessage {
  var this: TwitchMessage { return self }
}
public class ClearChatMessage: TwitchMessage {
  public var banDuration: Int?  // seconds, nil if perma

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

  init(irc: IRCMessage) {
    banDuration = Int(irc.tag["ban-duration"] ?? "")
    channelID = irc.tag["room-id"]!
    targetUserID = irc.tag["target-user-id"]

    let parts = irc.params.split(separator: " ", maxSplits: 1)
    channelLogin = String(parts[0].dropFirst(1))  // remove the # prefix before channel
    if parts.count == 2 {
      targetUserLogin = String(parts[1].dropFirst(1))  // remove the : prefix before user
    }

    super.init(id: NSUUID().uuidString, timestamp: Int64(irc.tag["tmi-sent-ts"]!)!)
  }
}
