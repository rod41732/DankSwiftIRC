
import DankSwiftIRC
import XCTest

class TestIRCParsingBenchmark: XCTestCase {
    func testIRCParseBenchmark() {
        let testFile = #file
        let data = (NSString.path(withComponents: [testFile, "../data.1000.txt"]) as NSString).standardizingPath
        
        let lines = try! String(contentsOfFile: data, encoding: .utf8).split(separator: "\n", omittingEmptySubsequences: true).map { it in String(it) }
        XCTAssertEqual(lines.count, 1000)

        var parsed: [TwitchMessage] = []
        parsed.reserveCapacity(1000)
        measure {
            for line in lines {
                parsed.append(IRCMessage(message: line).asTwitchMessage())
            }
            parsed.removeAll(keepingCapacity: true)
        }
    }
}
