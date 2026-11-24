import Darwin
import Foundation

/// The IPv4 address of this device on the Wi-Fi, and the other addresses of its /24 network.
/// `bridge100` is the network an iPhone makes when it shares its connection: the phone that
/// shares is then reachable, and can reach the others, like on any Wi-Fi.
nonisolated enum LocalAddress {
    private static let wifiInterfaces: Set<String> = ["en0", "en1", "bridge100"]
    private static let hostRange = 1...254

    static func wifiIPv4() -> String? {
        var list: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&list) == 0, let first = list else { return nil }
        defer { freeifaddrs(list) }
        for pointer in sequence(first: first, next: { $0.pointee.ifa_next }) {
            let entry = pointer.pointee
            guard let address = entry.ifa_addr, address.pointee.sa_family == UInt8(AF_INET),
                  wifiInterfaces.contains(String(cString: entry.ifa_name)) else { continue }
            var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            guard getnameinfo(address, socklen_t(address.pointee.sa_len), &host, socklen_t(host.count), nil, 0, NI_NUMERICHOST) == 0 else { continue }
            return String(decoding: host.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) }, as: UTF8.self)
        }
        return nil
    }

    /// Every other address of the /24 this device is on, or nothing off the Wi-Fi.
    static func neighbours() -> [String] {
        guard let own = wifiIPv4() else { return [] }
        let parts = own.split(separator: ".")
        guard parts.count == 4 else { return [] }
        let prefix = parts.prefix(3).joined(separator: ".")
        return hostRange.map { "\(prefix).\($0)" }.filter { $0 != own }
    }
}
