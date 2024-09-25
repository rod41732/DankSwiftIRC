import Foundation

public class NoticeMessage: TwitchMessage {
  public var messageType: String // type of notice -- too many to list as enum
  public var channelLogin: String
  public var message: String
  public var raw: IRCMessage

  // timestamp if known (e.g. from recent-message API, otherwise will default to receive time)
  public init(irc: IRCMessage, timestamp: Int64?) {
    raw = irc

    let parts = irc.params.split(byUnicodeScalar: " ", maxSplits: 1)
    channelLogin = String(parts[0].dropFirst())

    var rawMessage = String(parts[safe: 1] ?? "") // index safety
    if rawMessage.firstUnicodeScalar == ":" {
      rawMessage.dropFirstUnicodeScalar()
    }
    message = rawMessage

    // some message, notable authentication error message doesn't have type
    messageType = irc.tag["msg-id"] ?? "no-type"
    let finalizedTimestamp = timestamp ?? Int64(Date().timeIntervalSince1970 * 1000)

    super.init(id: "\(finalizedTimestamp)-\(channelLogin)-notice-\(messageType)", timestamp: timestamp ?? finalizedTimestamp)
  }

  override public func rawIRC() -> IRCMessage {
    return raw
  }
}
