import Foundation

private let bs = ("\\".utf8).first!
private let colon = (":".utf8).first!
private let semi = (";".utf8).first!
private let char_s = ("s".utf8).first!
private let space = (" ".utf8).first!
private let char_r = ("r".utf8).first!
private let cr = ("\r".utf8).first!
private let char_n = ("n".utf8).first!
private let new_line = ("\n".utf8).first!

public func unescape(_ s: String) -> String {
//    if s.firstIndex(of: "\\") == nil {
//        return s
//    }


    var raw = Data(s.utf8)
    var idx = 0
    var ptr = 0

    while idx < raw.count {
        let byte = raw[idx]
        switch byte {
        case bs:
            idx += 1
            // prevent crash on trailing bs
            if idx < raw.count {
                let nextByte = raw[idx]
                switch nextByte {
                case colon: raw[ptr] = semi
                case char_s: raw[ptr] = space
                case char_r: raw[ptr] = cr
                case char_n: raw[ptr] = new_line
                default: raw[ptr] = nextByte
                }
                ptr += 1
            }
        default:
            raw[ptr] = byte
            ptr += 1
        }
        idx += 1
    }
    return String(data: raw[..<ptr], encoding: .utf8)!
}

// IRCMessage represent single message according to IRCv3 https://ircv3.net/specs/extensions/message-tags.html
public class IRCMessage {
    public var message: String // raw message
    public var tag = [String: String]() // tags (key value)
    public var prefix: String = "" // prefix without :
    public var command: String!
    public var params: String!

    public init(message: String) {
        self.message = message
        parse()
    }

    func parse() {
        let unicodeView = message.unicodeScalars
        var unicodeIdx = unicodeView.startIndex
        if unicodeView[unicodeIdx] == "@" {
            let spaceIdx = unicodeView.firstIndex(of: " ")!
            let tagPart = unicodeView[unicodeView.index(after: unicodeIdx)..<spaceIdx]
            parseTags(Substring(tagPart))
            unicodeIdx = unicodeView.index(after: spaceIdx)
        }

        // prefix part
        if unicodeView[unicodeIdx] == ":" {
            let msub = unicodeView[unicodeIdx..<unicodeView.endIndex]
            let spaceIdx = msub.firstIndex(of: " ")!
            prefix = String(msub[msub.index(after: msub.startIndex)..<spaceIdx])
            unicodeIdx = unicodeView.index(after: spaceIdx)
        }

    // 
        let endPart = unicodeView[unicodeIdx..<unicodeView.endIndex]
        if let spaceIdx = endPart.firstIndex(of: " ") {
            command = String(endPart[..<spaceIdx])
            params = String(endPart[endPart.index(after: spaceIdx)...])
        } else {
            command = String(endPart)
            params = ""
        }
    }

    func parseTags(_ tagString: Substring) {
        var toParse = tagString.unicodeScalars[...]
        while true {
            if let idx = toParse.firstIndex(of: ";") {
                parseTagComponent(Substring(toParse[..<idx]))
                toParse = toParse[toParse.index(after: idx)...]
            } else {
                parseTagComponent(Substring(toParse))
                break
            }
        }
    }
    
    
    @inline(__always)
    func parseTagComponent(_ cmp: Substring) {
            if let idx = cmp.firstIndex(of: "=") {
                tag[String(cmp[..<idx])] = unescape(String(cmp[cmp.index(after: idx)...]))
            } else {
                tag[String(cmp)] = ""
            }
    }
}
