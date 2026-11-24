import Foundation

/// An address typed by hand: an IPv4, followed by its port after a colon when the device does
/// not listen on LocalSend's usual one (« 192.168.1.20 » or « 192.168.1.20:53318 »).
nonisolated struct ManualAddress: Equatable, Sendable {
    let host: String
    let port: Int

    /// The host, then the port when one is given.
    private static let maxParts = 2
    private static let octetCount = 4
    private static let octetRange = 0...255
    private static let portRange = 1...65_535
    private static let octetSeparator: Character = "."
    private static let portSeparator: Character = ":"

    /// nil unless `text` is an IPv4 address, with or without a valid port.
    init?(_ text: String) {
        let parts = text.trimmingCharacters(in: .whitespaces)
            .split(separator: Self.portSeparator, omittingEmptySubsequences: false)
        guard let hostPart = parts.first, parts.count <= Self.maxParts else { return nil }
        let octets = hostPart.split(separator: Self.octetSeparator, omittingEmptySubsequences: false)
        guard octets.count == Self.octetCount, octets.allSatisfy({ Self.number($0, in: Self.octetRange) != nil }) else {
            return nil
        }
        if parts.count == Self.maxParts {
            guard let portPart = parts.last, let port = Self.number(portPart, in: Self.portRange) else { return nil }
            self.port = port
        } else {
            port = Int(LocalSendProtocol.port)
        }
        host = String(hostPart)
    }

    /// How this device's own address is shown: the port only when it is not the usual one.
    static func display(host: String, port: Int) -> String {
        port == Int(LocalSendProtocol.port) ? host : "\(host)\(portSeparator)\(port)"
    }

    /// Plain ASCII digits within `range`; « +1 » or « ١ » are refused.
    private static func number(_ text: Substring, in range: ClosedRange<Int>) -> Int? {
        guard !text.isEmpty, text.allSatisfy({ $0.isASCII && $0.isNumber }), let value = Int(text) else { return nil }
        return range.contains(value) ? value : nil
    }
}
