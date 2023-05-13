import DankSwiftIRC
import XCTest
class UserNoticeMessageTest: XCTestCase {
  func testResubMessage() {
    let irc = #"@badge-info=;badges=staff/1,broadcaster/1,turbo/1;color=#008000;display-name=Ronni;emotes=;id=db25007f-7a18-43eb-9379-80131e44d633;login=ronni;mod=0;msg-id=resub;msg-param-cumulative-months=6;msg-param-streak-months=2;msg-param-should-share-streak=1;msg-param-sub-plan=Prime;msg-param-sub-plan-name=Prime;room-id=12345678;subscriber=1;system-msg=ronni\shas\ssubscribed\sfor\s6\smonths!;tmi-sent-ts=1507246572675;turbo=1;user-id=87654321;user-type=staff :tmi.twitch.tv USERNOTICE #dallas :Great stream -- keep it up!"#
    let message = IRCMessage(message: irc).asTwitchMessage()
    switch message {
    case let message as UserNoticeMessage:
      XCTAssertEqual(message.userColor, "#008000")
      XCTAssertEqual(message.userID, "87654321")
      XCTAssertEqual(message.userLogin, "ronni")
      XCTAssertEqual(message.displayName, "Ronni")
      XCTAssertEqual(message.message, "Great stream -- keep it up!")
      XCTAssertEqual(message.messageType, .resub)
      XCTAssertEqual(message.systemMessage, "ronni has subscribed for 6 months!")
      XCTAssertEqual(message.ritualType, nil)
    default:
      XCTFail("Expected to be parsed as USERNOTICE message")
    }
  }

  func testGiftSubMessage() {
    let irc = #"@badge-info=;badges=staff/1,premium/1;color=#0000FF;display-name=TWW2;emotes=;id=e9176cd8-5e22-4684-ad40-ce53c2561c5e;login=tww2;mod=0;msg-id=subgift;msg-param-months=1;msg-param-recipient-display-name=Mr_Woodchuck;msg-param-recipient-id=55554444;msg-param-recipient-name=mr_woodchuck;msg-param-sub-plan-name=House\sof\sNyoro~n;msg-param-sub-plan=1000;room-id=19571752;subscriber=0;system-msg=TWW2\sgifted\sa\sTier\s1\ssub\sto\sMr_Woodchuck!;tmi-sent-ts=1521159445153;turbo=0;user-id=87654321;user-type=staff :tmi.twitch.tv USERNOTICE #forstycup"#

    let message = IRCMessage(message: irc).asTwitchMessage()
    switch message {
    case let message as UserNoticeMessage:
      XCTAssertEqual(message.message, "") // blank message
      XCTAssertEqual(message.messageType, .subgift)
    default:
      XCTFail("Expected to be parsed as USERNOTICE message")
    }
  }

  func testNewChatterRitual() {
    let irc = #"@badge-info=;badges=;color=;display-name=SevenTest1;emotes=30259:0-6;id=37feed0f-b9c7-4c3a-b475-21c6c6d21c3d;login=seventest1;mod=0;msg-id=ritual;msg-param-ritual-name=new_chatter;room-id=87654321;subscriber=0;system-msg=Seventoes\sis\snew\shere!;tmi-sent-ts=1508363903826;turbo=0;user-id=77776666;user-type= :tmi.twitch.tv USERNOTICE #seventoes :HeyGuys"#
    let message = IRCMessage(message: irc).asTwitchMessage()
    switch message {
    case let message as UserNoticeMessage:
      XCTAssertEqual(message.message, "HeyGuys") // blank message
      XCTAssertEqual(message.emotes.count, 1) // too lazy to check each emote 4HEad
      XCTAssertEqual(message.messageType, .ritual)
      XCTAssertEqual(message.ritualType, .newChatter)
    default:
      XCTFail("Expected to be parsed as USERNOTICE message")
    }
  }
}
