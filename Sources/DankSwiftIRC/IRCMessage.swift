// IRCMessage represent single message according to IRCv3 https://ircv3.net/specs/extensions/message-tags.html
public class IRCMessage {
  public var message: String  // raw message
  public var tag = [String: String]()  // tags (key value)
  public var prefix: String = ""  // prefix without :
  public var command: String!
  public var params: String!

  public init(message: String) {
    self.message = message
    parse()
  }

  func parse() {
    var idx = message.startIndex
    if message[idx] == "@" {
      let spaceIdx = message.firstIndex(of: " ")!
      let tagPart = message[message.index(after: idx)..<spaceIdx]
      parseTags(String(tagPart))
      idx = message.index(after: spaceIdx)
    }

    if message[idx] == ":" {
      let msub = message[idx..<message.endIndex]
      let spaceIdx = msub.firstIndex(of: " ")!
      prefix = String(msub[msub.index(after: msub.startIndex)..<spaceIdx])
      idx = message.index(after: spaceIdx)
    }

    let parts = message[idx..<message.endIndex].split(
      separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
    command = String(parts[0])
    params = String(parts.count == 2 ? parts[1] : "")
  }

  func parseTags(_ tagString: String) {
    var newTag: [String: String] = [:]
    tagString.split(separator: ";").forEach({ it in
      if !it.contains("=") {
        newTag[String(it)] = ""
      } else {
        let parts = it.split(separator: "=", omittingEmptySubsequences: false)
        newTag[String(parts[0])] = String(parts[1])
      }
    })
    tag = newTag
  }
}
