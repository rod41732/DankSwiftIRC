import DankSwiftIRC

func parseAsTwitchMessage(_ message: String) -> TwitchMessage {
    return IRCMessage(from: IRCMessage3(message: message)).asTwitchMessage()
}
