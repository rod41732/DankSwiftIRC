
public class GlobalUserStateMessage: AutoIDMessage {
  public var emotesSets: [String] 
  override init(irc: IRCMessage) {
    emotesSets = irc.tag["emote-sets"]?.split(separator: ",", omittingEmptySubsequences: true)
    .map{ it in String(it) } ?? []

    super.init(irc: irc)
  }
  
  
}