import DankSwiftIRC

func parseAsTwitchMessage(_ message: String) -> TwitchMessage {
    return IRCMessage(fromMsg3: IRCMessage3(message: message)).asTwitchMessage()
}
