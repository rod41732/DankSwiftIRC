import XCTest
import DankSwiftIRC

class GlobalUserStateMessageTest: XCTestCase {
  func testParsingGlobalUserState1() {
    let irc = "@badge-info=subscriber/8;badges=subscriber/6;color=#0D4200;display-name=dallas;emote-sets=0,33,50,237,793,2126,3517,4578,5569,9400,10337,12239;turbo=0;user-id=12345678;user-type=admin :tmi.twitch.tv GLOBALUSERSTATE"
    let message = IRCMessage(message: irc).asTwitchMessage()
    switch message {
      case let message as GlobalUserStateMessage:
        XCTAssertEqual(message.emotesSets, ["0","33","50","237","793","2126","3517","4578","5569","9400","10337","12239"])
      default:
        XCTFail("Expected Message to be GlobalUserStateMessage")
    }

  }
}