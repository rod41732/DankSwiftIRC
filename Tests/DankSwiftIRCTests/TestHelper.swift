import DankSwiftIRC

func parseAsTwitchMessage(_ message: String) -> TwitchMessage {
    return IRCMessage(message: message).asTwitchMessage()
}
