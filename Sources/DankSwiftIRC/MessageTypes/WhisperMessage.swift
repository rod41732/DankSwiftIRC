import Foundation

extension String? {
  func valueIfEmpty(_ val: String) -> String {
    if self == nil || self == "" {
      return val
    }
    return self!
  }
}

public class WhisperMessage: TwitchMessage {
  public var raw: IRCMessage

  public var senderDisplayName: String
  public var senderLogin: String
  public var senderID: String
  public var senderColor: String
  public var emotes: [PrivMessageEmote]

  public var message: String // body of message

  public var receiverLogin: String
  public var receiverID: String?

  // NOTE: twitch IRC don't give us timestamp for whisper message
  init(irc: IRCMessage, timestamp: Int64? = nil) {
    raw = irc

    senderColor = irc.tag["color"] ?? ""
    senderLogin = String(irc.prefix[..<irc.prefix.firstIndex(of: "!")!])
    senderDisplayName = irc.tag["display-name"].valueIfEmpty(senderLogin)
    let senderID = irc.tag["user-id"]! // define local var to workaround; error: 'self' captured by a closure before all members were initialized
    self.senderID = senderID

    let parts = irc.params.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
    receiverLogin = String(parts[0])
    let rawMesage = parts[1]

    message = String(rawMesage.first == ":" ? rawMesage.dropFirst() : rawMesage)

    if let threadID = irc.tag["thread-id"] {
      let parts = threadID.components(separatedBy: "_")
      let notSenderID = parts.filter { it in it != senderID }.first
      receiverID = notSenderID
    }

    emotes = parseEmotes(raw: irc.tag["emotes"] ?? "", message: message)

    super.init(
      id: irc.tag["message-id"]!,
      timestamp: timestamp ?? Int64(Date.now.timeIntervalSince1970 * 1000)
    )
  }
}
