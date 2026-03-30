import Foundation

// IRCMessage represent single message according to IRCv3 https://ircv3.net/specs/extensions/message-tags.html
// Single-pass: copy + unescape + record offsets in one pass
public class IRCMessage2 {
    public var message: String  // raw message
    public var tag = ContiguousArray<(Substring, Substring)>()  // tags (key, value)
    public var prefix: Substring = ""  // prefix without :
    public var command: Substring!
    public var params: Substring!

    // the unescaped string that substrings reference
    var _unescaped: String!

    public init(message: String) {
        self.message = message
        parse()
    }

    func parse() {
        var offsets = ContiguousArray<Int>()
        offsets.reserveCapacity(200)

        _unescaped = String(unsafeUninitializedCapacity: message.utf8.count) { outBuf in
            return message.withCString { srcBuf in
                let n = strlen(srcBuf)
                var r = 0  // read index
                var w = 0  // write index

                // parse tags
                if srcBuf[r] == 64 {  // '@'
                    r += 1
                    var tagEnd = r
                    while tagEnd < n && srcBuf[tagEnd] != 32 { tagEnd += 1 }

                    while r < tagEnd {
                        // key (no unescaping)
                        let keyStart = w
                        while r < tagEnd && srcBuf[r] != 61 && srcBuf[r] != 59 {  // '=' or ';'
                            outBuf[w] = UInt8(bitPattern: srcBuf[r])
                            r += 1
                            w += 1
                        }
                        let keyEnd = w

                        if r < tagEnd && srcBuf[r] == 61 {  // '='
                            r += 1
                            let valStart = w
                            while r < tagEnd && srcBuf[r] != 59 {  // ';'
                                if srcBuf[r] == 92 {  // backslash — unescape
                                    r += 1
                                    if r < tagEnd {
                                        switch srcBuf[r] {
                                        case 58: outBuf[w] = 59  // \: → ;
                                        case 115: outBuf[w] = 32  // \s → space
                                        case 114: outBuf[w] = 13  // \r → CR
                                        case 110: outBuf[w] = 10  // \n → LF
                                        default: outBuf[w] = UInt8(bitPattern: srcBuf[r])
                                        }
                                    }
                                } else {
                                    outBuf[w] = UInt8(bitPattern: srcBuf[r])
                                }
                                r += 1
                                w += 1
                            }
                            let valEnd = w
                            offsets.append(contentsOf: [keyStart, keyEnd, valStart, valEnd])
                        } else {
                            offsets.append(contentsOf: [keyStart, keyEnd, keyEnd, keyEnd])
                        }

                        if r < tagEnd && srcBuf[r] == 59 { r += 1 }  // skip ';'
                    }
                    r += 1  // skip space after tags
                }
                offsets.append(-1)  // sentinel: end of tags

                // prefix
                if r < n && srcBuf[r] == 58 {  // ':'
                    r += 1
                    let s = w
                    while r < n && srcBuf[r] != 32 {
                        outBuf[w] = UInt8(bitPattern: srcBuf[r])
                        r += 1
                        w += 1
                    }
                    offsets.append(contentsOf: [s, w])
                    r += 1  // skip space
                } else {
                    offsets.append(contentsOf: [-1, -1])
                }

                // command
                let cs = w
                while r < n && srcBuf[r] != 32 {
                    outBuf[w] = UInt8(bitPattern: srcBuf[r])
                    r += 1
                    w += 1
                }
                offsets.append(contentsOf: [cs, w])

                // params
                if r < n {
                    r += 1  // skip space
                    let ps = w
                    while r < n {
                        outBuf[w] = UInt8(bitPattern: srcBuf[r])
                        r += 1
                        w += 1
                    }
                    offsets.append(contentsOf: [ps, w])
                } else {
                    offsets.append(contentsOf: [w, w])
                }

                return w
            }
        }

        // Create substrings from _unescaped using offsets
        let utf8 = _unescaped.utf8
        let start = utf8.startIndex
        var i = 0

        // tags
        while offsets[i] != -1 {
            let k = Substring(
                utf8[
                    utf8.index(
                        start, offsetBy: offsets[i])..<utf8.index(start, offsetBy: offsets[i + 1])])
            let v = Substring(
                utf8[
                    utf8.index(
                        start, offsetBy: offsets[i + 2])..<utf8.index(
                            start, offsetBy: offsets[i + 3])])
            tag.append((k, v))
            i += 4
        }
        i += 1  // skip sentinel

        // prefix
        if offsets[i] != -1 {
            prefix = Substring(
                utf8[
                    utf8.index(
                        start, offsetBy: offsets[i])..<utf8.index(start, offsetBy: offsets[i + 1])])
        }
        i += 2

        // command
        command = Substring(
            utf8[
                utf8.index(
                    start, offsetBy: offsets[i])..<utf8.index(start, offsetBy: offsets[i + 1])])
        i += 2

        // params
        params = Substring(
            utf8[
                utf8.index(
                    start, offsetBy: offsets[i])..<utf8.index(start, offsetBy: offsets[i + 1])])
    }
}

// Two-pass approach: scan first, only copy+unescape if needed
public class IRCMessage3 {
    public var message: String  // raw message
    public var tag = ContiguousArray<(Substring, Substring)>()  // tags (key, value)
    public var prefix: Substring = ""  // prefix without :
    public var command: Substring!
    public var params: Substring!

    // backing string for substrings (either message itself or unescaped copy)
    var _base: String!

    public init(message: String) {
        self.message = message
        parse()
    }

    func parse() {
        var offsets = ContiguousArray<Int>()
        offsets.reserveCapacity(200)
        var needUnescape = false

        // Pass 1: scan only, record offsets into original string
        message.withCString { buf in
            let n = strlen(buf)
            var x = 0

            if buf[x] == 64 {  // '@'
                x += 1
                var tagEnd = x
                while tagEnd < n && buf[tagEnd] != 32 { tagEnd += 1 }

                while x < tagEnd {
                    let keyStart = x
                    while x < tagEnd && buf[x] != 61 && buf[x] != 59 {
                        x += 1
                    }
                    let keyEnd = x

                    if x < tagEnd && buf[x] == 61 {  // '='
                        x += 1
                        let valStart = x
                        while x < tagEnd && buf[x] != 59 {
                            if buf[x] == 92 { needUnescape = true }  // backslash
                            x += 1
                        }
                        let valEnd = x
                        offsets.append(contentsOf: [keyStart, keyEnd, valStart, valEnd])
                    } else {
                        offsets.append(contentsOf: [keyStart, keyEnd, keyEnd, keyEnd])
                    }
                    if x < tagEnd && buf[x] == 59 { x += 1 }
                }
                x += 1  // skip space
            }
            offsets.append(-1)

            if x < n && buf[x] == 58 {  // ':'
                x += 1
                let s = x
                while x < n && buf[x] != 32 { x += 1 }
                offsets.append(contentsOf: [s, x])
                x += 1
            } else {
                offsets.append(contentsOf: [-1, -1])
            }

            let cs = x
            while x < n && buf[x] != 32 { x += 1 }
            offsets.append(contentsOf: [cs, x])

            if x < n {
                x += 1
                offsets.append(contentsOf: [x, n])
            } else {
                offsets.append(contentsOf: [x, x])
            }
        }

        if needUnescape {
            // Slow path: copy + unescape, re-record offsets
            offsets.removeAll(keepingCapacity: true)

            _base = String(unsafeUninitializedCapacity: message.utf8.count) { outBuf in
                return message.withCString { srcBuf in
                    let n = strlen(srcBuf)
                    var r = 0
                    var w = 0

                    if srcBuf[r] == 64 {
                        r += 1
                        var tagEnd = r
                        while tagEnd < n && srcBuf[tagEnd] != 32 { tagEnd += 1 }

                        while r < tagEnd {
                            let keyStart = w
                            while r < tagEnd && srcBuf[r] != 61 && srcBuf[r] != 59 {
                                outBuf[w] = UInt8(bitPattern: srcBuf[r])
                                r += 1
                                w += 1
                            }
                            let keyEnd = w

                            if r < tagEnd && srcBuf[r] == 61 {
                                r += 1
                                let valStart = w
                                while r < tagEnd && srcBuf[r] != 59 {
                                    if srcBuf[r] == 92 {
                                        r += 1
                                        if r < tagEnd {
                                            switch srcBuf[r] {
                                            case 58: outBuf[w] = 59
                                            case 115: outBuf[w] = 32
                                            case 114: outBuf[w] = 13
                                            case 110: outBuf[w] = 10
                                            default: outBuf[w] = UInt8(bitPattern: srcBuf[r])
                                            }
                                        }
                                    } else {
                                        outBuf[w] = UInt8(bitPattern: srcBuf[r])
                                    }
                                    r += 1
                                    w += 1
                                }
                                let valEnd = w
                                offsets.append(contentsOf: [keyStart, keyEnd, valStart, valEnd])
                            } else {
                                offsets.append(contentsOf: [keyStart, keyEnd, keyEnd, keyEnd])
                            }
                            if r < tagEnd && srcBuf[r] == 59 { r += 1 }
                        }
                        r += 1
                    }
                    offsets.append(-1)

                    if r < n && srcBuf[r] == 58 {
                        r += 1
                        let s = w
                        while r < n && srcBuf[r] != 32 {
                            outBuf[w] = UInt8(bitPattern: srcBuf[r])
                            r += 1
                            w += 1
                        }
                        offsets.append(contentsOf: [s, w])
                        r += 1
                    } else {
                        offsets.append(contentsOf: [-1, -1])
                    }

                    let cs = w
                    while r < n && srcBuf[r] != 32 {
                        outBuf[w] = UInt8(bitPattern: srcBuf[r])
                        r += 1
                        w += 1
                    }
                    offsets.append(contentsOf: [cs, w])

                    if r < n {
                        r += 1
                        let ps = w
                        while r < n {
                            outBuf[w] = UInt8(bitPattern: srcBuf[r])
                            r += 1
                            w += 1
                        }
                        offsets.append(contentsOf: [ps, w])
                    } else {
                        offsets.append(contentsOf: [w, w])
                    }

                    return w
                }
            }
        } else {
            // Fast path: use original string directly
            _base = message
        }

        // Create substrings from _base using offsets
        let utf8 = _base.utf8
        let start = utf8.startIndex
        var i = 0

        while offsets[i] != -1 {
            let k = Substring(
                utf8[
                    utf8.index(
                        start, offsetBy: offsets[i])..<utf8.index(start, offsetBy: offsets[i + 1])])
            let v = Substring(
                utf8[
                    utf8.index(
                        start, offsetBy: offsets[i + 2])..<utf8.index(
                            start, offsetBy: offsets[i + 3])])
            tag.append((k, v))
            i += 4
        }
        i += 1

        if offsets[i] != -1 {
            prefix = Substring(
                utf8[
                    utf8.index(
                        start, offsetBy: offsets[i])..<utf8.index(start, offsetBy: offsets[i + 1])])
        }
        i += 2

        command = Substring(
            utf8[
                utf8.index(
                    start, offsetBy: offsets[i])..<utf8.index(start, offsetBy: offsets[i + 1])])
        i += 2

        params = Substring(
            utf8[
                utf8.index(
                    start, offsetBy: offsets[i])..<utf8.index(start, offsetBy: offsets[i + 1])])
    }
}
