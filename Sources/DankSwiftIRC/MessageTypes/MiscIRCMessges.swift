public class PingMessage: AutoIDMessage {
  public var pingPayload: String // e.g. PING [:tmi.twitch.tv] <- payload
  override init(irc: IRCMessage) {
    pingPayload = irc.params
    super.init(irc: irc)
  }
}

public class PartMessage: AutoIDMessage {
  public var channels: [String]

  override init(irc: IRCMessage) {
    let channelsPart = irc.params.components(separatedBy: " ").first!
    let channels = channelsPart.components(separatedBy: ",").map { String($0.dropFirst(1)) }
    self.channels = channels
    super.init(irc: irc)
  }
}

public class JoinMessage: AutoIDMessage {
  public var channels: [String]

  override init(irc: IRCMessage) {
    let channelsPart = irc.params.components(separatedBy: " ").first!
    let channels = channelsPart.components(separatedBy: ",").map { String($0.dropFirst(1)) }
    self.channels = channels
    super.init(irc: irc)
  }
}


public class ReconnectMessage: AutoIDMessage {
  override init(irc: IRCMessage) {
    super.init(irc: irc)
  }
}