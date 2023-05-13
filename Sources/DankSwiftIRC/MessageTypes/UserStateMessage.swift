import Foundation

public class UserStateMessage: AutoIDMessage {
  public var channelLogin: String
  // NOTE: many more tags avaiable, but intentionally not parsed
  public var emoteSets: [String]
  public var clientNonce: String? // included as response for PRIVMSG if client-nonce was sent

  override public init(irc: IRCMessage) {
    emoteSets =
      irc.tag["emote-sets"]?.split(separator: ",", omittingEmptySubsequences: true)
        .map { it in String(it) } ?? []
    clientNonce = irc.tag["client-nonce"]

    channelLogin = String(irc.params.dropFirst())

    super.init(irc: irc)
  }
}
