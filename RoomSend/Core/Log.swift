import OSLog

/// The app's loggers, one per area. Messages are for developers; users read the interface.
nonisolated enum Log {
    private static let subsystem = "app.roomsend.ios"

    static let identity = Logger(subsystem: subsystem, category: "identity")
    static let discovery = Logger(subsystem: subsystem, category: "discovery")
    static let transfer = Logger(subsystem: subsystem, category: "transfer")
    static let content = Logger(subsystem: subsystem, category: "content")
    static let history = Logger(subsystem: subsystem, category: "history")
    static let server = Logger(subsystem: subsystem, category: "server")
    static let receive = Logger(subsystem: subsystem, category: "receive")
}
