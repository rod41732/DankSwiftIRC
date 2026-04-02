import DankSwiftIRC
import XCTest

class TestIRCParsingBenchmark2: XCTestCase {
    func testIRCParseBenchmark2() {
        let testFile = #file
        let data = (NSString.path(withComponents: [testFile, "../data.1000.txt"]) as NSString)
            .standardizingPath

        let lines = try! String(contentsOfFile: data, encoding: .utf8).split(
            separator: "\n", omittingEmptySubsequences: true
        ).map { it in String(it) }
        XCTAssertEqual(lines.count, 1000)

        var parsed: ContiguousArray<IRCMessage2> = []
        parsed.reserveCapacity(1000)
        measure {
            for line in lines {
                parsed.append(IRCMessage2(message: line))
            }
        }
    }

    /// IRCMessage3: two-pass (scan + conditional unescape)
    func testIRCParseBenchmark3() {
        let testFile = #file
        let data = (NSString.path(withComponents: [testFile, "../data.1000.txt"]) as NSString)
            .standardizingPath

        let lines = try! String(contentsOfFile: data, encoding: .utf8).split(
            separator: "\n", omittingEmptySubsequences: true
        ).map { it in String(it) }
        XCTAssertEqual(lines.count, 1000)

        var parsed: ContiguousArray<IRCMessage3> = []
        parsed.reserveCapacity(1000)
        measure {
            for line in lines {
                parsed.append(IRCMessage3(message: line))
            }
        }
    }

    /// Parse with IRCMessage2, then convert to IRCMessage (Substring -> String)
    // func testIRCParseBenchmark2ThenConvert() {
    //     let testFile = #file
    //     let data = (NSString.path(withComponents: [testFile, "../data.1000.txt"]) as NSString)
    //         .standardizingPath

    //     let lines = try! String(contentsOfFile: data, encoding: .utf8).split(
    //         separator: "\n", omittingEmptySubsequences: true
    //     ).map { it in String(it) }
    //     XCTAssertEqual(lines.count, 1000)

    //     var parsed: [IRCMessage] = []
    //     parsed.reserveCapacity(1000)
    //     measure {
    //         for line in lines {
    //             parsed.append(IRCMessage(from: IRCMessage2(message: line)))
    //         }
    //     }
    // }
}
