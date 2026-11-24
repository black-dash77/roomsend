import Foundation

/// The device types of LocalSend (protocol v2.2, section 7.1).
nonisolated enum DeviceType: String, Codable, Sendable {
    case mobile, desktop, web, headless, server

    /// The SF Symbol of the badge drawn on a device's avatar.
    var symbolName: String {
        switch self {
        case .mobile: "iphone"
        case .desktop: "desktopcomputer"
        case .web: "globe"
        case .headless: "terminal"
        case .server: "server.rack"
        }
    }
}

/// Who this device is on the Wi-Fi: the alias the others see, and the fingerprint that tells
/// devices apart: the SHA-256 of its TLS certificate, or a random string when the keychain could
/// not hold one (protocol section 2).
nonisolated struct DeviceIdentity: Codable, Equatable, Sendable {
    var alias: String
    var fingerprint: String
    let deviceModel: String
    let deviceType: DeviceType
}
