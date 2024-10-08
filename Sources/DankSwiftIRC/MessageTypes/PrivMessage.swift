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

public class StringIndexer {
    private let string: String
    private let scalars: String.UnicodeScalarView
    private var cacheIndex: (Int, String.UnicodeScalarIndex)?

    public init(string: String) {
        self.string = string
        scalars = self.string.unicodeScalars
    }

    public func getUnicodeRange(from: Int, to: Int) -> String {
        let baseInt: Int
        let index: String.UnicodeScalarIndex
        if let cacheIndex {
            (baseInt, index) = cacheIndex
        } else {
            index = scalars.startIndex
            baseInt = 0
        }

        let fromIndex = scalars.index(index, offsetBy: from - baseInt)
        let toIndex = scalars.index(fromIndex, offsetBy: to - from)
        cacheIndex = (to, toIndex)

        return String(scalars[fromIndex ..< toIndex])
    }
}

func parseEmotes(raw: String, message: String) -> [PrivMessageEmote] {
    let indexer = StringIndexer(string: message)
    return raw.components(separatedBy: "/").flatMap { part in
        if part.isEmpty { return [PrivMessageEmote]() }
        return parseEmote(part, message: indexer)
    }
}


public func parseEmote(_ part: String, message: StringIndexer) -> [PrivMessageEmote] { // 100000:1-2,3-4
    let parts = part.split(separator: ":", maxSplits: 1)
    let emoteID = String(parts[0])
    var name: String?

    return parts[1].components(separatedBy: ",").map { range in
        let dashIdx = range.firstIndex(of: "-")!
        let from = Int(range[..<dashIdx])!
        let to = Int(range[range.index(after: dashIdx)...])!
        if name == nil {
            name = message.getUnicodeRange(from: from, to: to + 1) // twitch indexing is inclusive end
        }
        return PrivMessageEmote(emoteID: emoteID, name: name!, position: (from, to))
    }
}

extension String {
    func isActionMessage() -> Bool {
        let prefix = String(self.unicodeScalars.prefix(8))
        let suffix = self.unicodeScalars.last
        return prefix == "\u{1}ACTION " && suffix == "\u{1}"
    }

    mutating func trimAction() {
        self.dropFirstUnicodeScalar(count: 8)
        self.unicodeScalars.removeLast()
    }
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

    // the message that is replied to, is supposed to show in the UI
    public var parentMessageId: String?
    public var parentUserId: String?
    public var parentUserLogin: String?
    public var parentDisplayName: String?
    public var parentBody: String?

    // the "root" of thread
    public var threadParentMessageId: String?
    public var threadParentUserId: String?
    public var threadParentUserLogin: String?
    public var threadParentDisplayName: String?

    // reward of redeeming point, this is only for redemption with message
    public var customRewardId: String?

    public init(irc: IRCMessage) {
        raw = irc

        userColor = irc.tag["color"] ?? ""
        userLogin = String(irc.prefix[..<irc.prefix.firstIndex(of: "!")!])
        displayName = irc.tag["display-name"] ?? userLogin
        channelID = irc.tag["room-id"]!
        userID = irc.tag["user-id"]!

        let parts = irc.params.split(byUnicodeScalar: " ", maxSplits: 1)
        let channelPart = parts[0]
        var rawMessage = parts[1]

        channelLogin = String(channelPart.dropFirst(1)) // drop #

        //
        if rawMessage.firstUnicodeScalar == ":" {
            rawMessage.dropFirstUnicodeScalar()
        } 

        isAction = rawMessage.isActionMessage()
        if isAction {
            rawMessage.trimAction()
        }
        
        self.message = rawMessage

        emotes = parseEmotes(raw: irc.tag["emotes"] ?? "", message: rawMessage).sorted(by: { m1, m2 in
            m1.position.0 < m2.position.0
        })

        // reply
        parentMessageId = irc.tag["reply-parent-msg-id"]
        parentUserId = irc.tag["reply-parent-user-id"]
        parentUserLogin = irc.tag["reply-parent-user-login"]
        parentDisplayName = irc.tag["reply-parent-display-name"]
        parentBody = irc.tag["reply-parent-msg-body"]

        // thread parent
        threadParentMessageId = irc.tag["reply-thread-parent-msg-id"]
        threadParentUserId = irc.tag["reply-thread-parent-user-id"]
        threadParentUserLogin = irc.tag["reply-thread-parent-user-login"]
        threadParentDisplayName = irc.tag["reply-thread-parent-display-name"]

        // rewards
        customRewardId = irc.tag["custom-reward-id"]

        super.init(id: irc.tag["id"]!, timestamp: Int64(irc.tag["tmi-sent-ts"]!)!)

        stripReplyUsernamePrefix()
    }

    private func stripReplyUsernamePrefix() {
        guard parentMessageId != nil else { return }
        guard message.starts(with: "@" + parentDisplayName!) else { return }
        // prevent crash when message body (after @username prefix) si
        let prefixLength = min(2 + parentDisplayName!.unicodeScalars.count, message.unicodeScalars.count)
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

    override public func rawIRC() -> IRCMessage {
        return raw
    }
}
