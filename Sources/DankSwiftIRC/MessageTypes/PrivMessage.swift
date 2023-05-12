public struct PrivMessageEmote: Equatable {
  public static func == (lhs: PrivMessageEmote, rhs: PrivMessageEmote) -> Bool {
    return lhs.emoteID == rhs.emoteID && lhs.name == rhs.name && lhs.position == rhs.position
  }

  public var emoteID: String
  public var name: String
  public var position: (Int, Int)

  public init(emoteID: String, name: String, position: (Int, Int)) {
    self.emoteID = emoteID
    self.name = name
    self.position = position
  }
}

func parseEmotes(raw: String, message: String) -> [PrivMessageEmote] {
  return raw.components(separatedBy: "/").flatMap { part in
    if part.isEmpty { return [PrivMessageEmote]() }
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

public func parseEmote(_ part: String, message: String) -> [PrivMessageEmote] { // 100000:1-2,3-4
  let parts = part.components(separatedBy: ":")

  let emoteID = parts[0]

  let positions = parts[1].components(separatedBy: ",").map { range in
    let nums = range.components(separatedBy: "-")
    return (Int(nums[0])!, Int(nums[1])!)
  }
  let (from, to) = positions[0]
  let name = message.unicodeSubstring(from: from, to: to + 1) // twitch indexing is inclusive end

  return positions.map { it in PrivMessageEmote(emoteID: emoteID, name: name, position: it) }
}

public class PrivMessage: TwitchMessage {
  public var userColor: String // color in hex like #aabbcc, or empty if user haven't set any color
  public var userLogin: String
  public var userID: String
  public var displayName: String
  public var emotes: [PrivMessageEmote]

  public var channelLogin: String
  public var channelID: String

  public var message: String
  public var isAction: Bool // is /me message

  public var raw: IRCMessage

  public var parentMessageId: String?
  public var parentUserId: String?
  public var parentUserLogin: String?
  public var parentDisplayName: String?
  public var parentBody: String?

  // reward of redeeming point, this is only for redemption with message
  public var customRewardId: String?

  public init(irc: IRCMessage) {
    raw = irc

    userColor = irc.tag["color"] ?? ""
    userLogin = String(irc.prefix[..<irc.prefix.firstIndex(of: "!")!])
    displayName = irc.tag["display-name"] ?? userLogin
    channelID = irc.tag["room-id"]!
    userID = irc.tag["user-id"]!

    let parts = irc.params.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
    let channelPart = parts[0]
    let messagePart = parts[1]

    channelLogin = String(channelPart.dropFirst(1))

    //
    let rawMessage = messagePart.first == ":" ? messagePart.dropFirst(1) : messagePart
    isAction = rawMessage.prefix(8) == "\u{1}ACTION "
    message = String(isAction ? rawMessage.dropFirst(8).dropLast(1) : rawMessage)

    emotes = parseEmotes(raw: irc.tag["emotes"] ?? "", message: message).sorted(by: { m1, m2 in
      m1.position.0 < m2.position.0
    })

    // reply
    if let parentId = irc.tag["reply-parent-msg-id"] {
      parentMessageId = parentId
      parentUserId = irc.tag["reply-parent-user-id"]!
      parentUserLogin = irc.tag["reply-parent-user-login"]!
      parentDisplayName = irc.tag["reply-parent-display-name"]!
      parentBody = irc.tag["reply-parent-msg-body"]!
    }
    // rewards
    customRewardId = irc.tag["custom-reward-id"]

    super.init(id: irc.tag["id"]!, timestamp: Int64(irc.tag["tmi-sent-ts"]!)!)

    stripReplyUsernamePrefix()
  }

  private func stripReplyUsernamePrefix() {
    guard parentMessageId != nil else { return }
    guard message.starts(with: "@" + parentDisplayName!) else { return }
    let prefixLength = 2 + parentDisplayName!.unicodeScalars.count
    let strippedMessage = message.unicodeSubstring(from: prefixLength, to: message.unicodeScalars.count)
    let offsetedEmotes = emotes.map { it in
      PrivMessageEmote(
        emoteID: it.emoteID,
        name: it.name,
        position: (it.position.0 - prefixLength, it.position.1 - prefixLength)
      )
    }
    message = strippedMessage
    emotes = offsetedEmotes
  }
}
