import DankSwiftIRC
import XCTest

/// blank test that only measure iterating through string
class TestIRCParsingStringIterationBenchmark: XCTestCase {


    /// test using for loop `for c in line.utf8`
    func testForLoopUTF8() {
        let testFile = #file
        let data = (NSString.path(withComponents: [testFile, "../data.1000.txt"]) as NSString)
            .standardizingPath

        let lines = try! String(contentsOfFile: data, encoding: .utf8).split(
            separator: "\n", omittingEmptySubsequences: true
        ).map { it in String(it) }
        XCTAssertEqual(lines.count, 1000)

        var sum: UInt8 = 0
        measure {
            for i in 0..<10 {
                for line in lines {
                    for c in line.utf8 {
                        sum |= c
                    }
                }
            }
        }
    }

    func testUTF8CString() {
        let testFile = #file
        let data = (NSString.path(withComponents: [testFile, "../data.1000.txt"]) as NSString)
            .standardizingPath

        let lines = try! String(contentsOfFile: data, encoding: .utf8).split(
            separator: "\n", omittingEmptySubsequences: true
        ).map { it in String(it) }
        XCTAssertEqual(lines.count, 1000)

        var sum: Int8 = 0
        measure {
            for i in 0..<10 {
                for line in lines {
                    line.withCString { buf in
                        let len = strlen(buf)
                        var x = 0
                        while x < len {
                            sum |= buf[x]
                            x += 1
                        }
                    }

                }
            }
        }
    }
}
