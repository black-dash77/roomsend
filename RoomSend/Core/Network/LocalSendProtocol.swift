import Foundation

/// The constants of the LocalSend protocol v2.2 (defaults, section 1).
nonisolated enum LocalSendProtocol {
    static let version = "2.2"
    static let multicastHost = "224.0.0.167"
    static let port: UInt16 = 53317
    static let apiPath = "/api/localsend/v2"
    static let maxDatagramSize = 65_535
}

nonisolated enum TransportProtocol: String, Codable, Sendable {
    case http, https
}

/// What a device says about itself: in its multicast announcement (section 3.1) and in the
/// `info` of a transfer request (section 4.1). The device type stays a string, so a value
/// added by a newer client does not make the whole message unreadable.
nonisolated struct DeviceInfo: Codable, Equatable, Sendable {
    let alias: String
    let version: String
    let deviceModel: String?
    let deviceType: String?
    let fingerprint: String
    let port: Int?
    let `protocol`: TransportProtocol?
    let download: Bool?
    let announce: Bool?

    init(
        alias: String, version: String, deviceModel: String?, deviceType: String?, fingerprint: String,
        port: Int?, protocol transport: TransportProtocol?, download: Bool?, announce: Bool?
    ) {
        self.alias = alias
        self.version = version
        self.deviceModel = deviceModel
        self.deviceType = deviceType
        self.fingerprint = fingerprint
        self.port = port
        `protocol` = transport
        self.download = download
        self.announce = announce
    }

    /// This device, as it presents itself on the chosen port and transport.
    init(identity: DeviceIdentity, transport: TransportProtocol, port: UInt16, announce: Bool?) {
        self.init(
            alias: identity.alias, version: LocalSendProtocol.version, deviceModel: identity.deviceModel,
            deviceType: identity.deviceType.rawValue, fingerprint: identity.fingerprint, port: Int(port),
            protocol: transport, download: false, announce: announce
        )
    }
}

/// A device heard on the Wi-Fi, with the address its announcement came from.
nonisolated struct NearbyDevice: Identifiable, Equatable, Sendable {
    let info: DeviceInfo
    let host: String

    var id: String { info.fingerprint }
    var alias: String { info.alias }
    var type: DeviceType? { info.deviceType.flatMap(DeviceType.init(rawValue:)) }
    var transport: TransportProtocol { info.protocol ?? .https }

    /// The root of its HTTP API, e.g. `https://192.168.1.20:53317/api/localsend/v2`.
    var apiURL: URL? {
        var components = URLComponents()
        components.scheme = transport.rawValue
        components.host = host
        components.port = info.port ?? Int(LocalSendProtocol.port)
        components.path = LocalSendProtocol.apiPath
        return components.url
    }
}
