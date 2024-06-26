public enum UserNoticeMessageType: String {
  // TODO:
  case sub
  case resub
  case subgift
  case submysterygift
  case giftpaidupgrade
  case rewardgift
  case anongiftpaidupgrade
  case raid
  case unraid
  case ritual
  case bitsbadgetier
  case announcement
}

public enum UserNoticeRitualType: String {
  case newChatter = "new_chatter"
}

public class UserNoticeMessage: TwitchMessage {
  public var userColor: String // color in hex like #aabbcc, or empty if user haven't set any color
  public var userLogin: String
  public var userID: String
  public var displayName: String
  public var emotes: [PrivMessageEmote]

  public var channelLogin: String
  public var channelID: String

  // body of message, only present for some type of message that allow user to input (e.g. sub message)
  public var message: String

  public var raw: IRCMessage

  // system rendered message like "XXX Subscribed to channel for X months in a row"
  public var systemMessage: String
  public var messageType: UserNoticeMessageType? // this will be nil if type is unknown
  public var ritualType: UserNoticeRitualType? // only present when messageType = .ritual

  // TODO: might parse msg-param-xxx-tags, right now just retrieve from irc.tag
  public init(irc: IRCMessage) {
    raw = irc

    userColor = irc.tag["color"] ?? ""
    userLogin = irc.tag["login"]!
    displayName = irc.tag["display-name"] ?? userLogin
    channelID = irc.tag["room-id"]!
    userID = irc.tag["user-id"]!

    let parts = irc.params.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
    let channelPart = parts[0]
    // handle possible empty message
    let messagePart = parts[safe: 1] ?? ""

    channelLogin = String(channelPart.dropFirst(1))
    message = String(messagePart.first == ":" ? messagePart.dropFirst(1) : messagePart)

    emotes = parseEmotes(raw: irc.tag["emotes"] ?? "", message: message).sorted(by: { m1, m2 in
      m1.position.0 < m2.position.0
    })

    systemMessage = irc.tag["system-msg"] ?? ""
    messageType = UserNoticeMessageType(rawValue: irc.tag["msg-id"] ?? "")
    ritualType = UserNoticeRitualType(rawValue: irc.tag["msg-param-ritual-name"] ?? "")

    super.init(id: irc.tag["id"]!, timestamp: Int64(irc.tag["tmi-sent-ts"]!)!)
  }

  override public func rawIRC() -> IRCMessage {
    return raw
  }
}
