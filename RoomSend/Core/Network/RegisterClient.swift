import CryptoKit
import Foundation
import OSLog

/// `POST /register` (protocol v2.2, sections 3.1 and 3.2): tells a device who we are and reads
/// who it is. Used to answer an announcement, and address by address when multicast is silent.
nonisolated struct RegisterClient: Sendable {
    let sender: DeviceInfo

    private static let answerTimeout: TimeInterval = 4
    private static let scanTimeout: TimeInterval = 1.5
    private static let scanWidth = 32

    /// Answers an announcement over HTTP; false when the device could not be reached.
    func answer(_ device: NearbyDevice) async -> Bool {
        guard let url = device.apiURL?.appending(path: "register") else { return false }
        return await post(to: url, expecting: device.id, timeout: Self.answerTimeout) != nil
    }

    /// Asks every neighbour on `port`; returns the devices that answered, with their address.
    func scan(hosts: [String], port: Int, transport: TransportProtocol) async -> [NearbyDevice] {
        var found: [NearbyDevice] = []
        for batch in stride(from: 0, to: hosts.count, by: Self.scanWidth) {
            let slice = hosts[batch..<min(batch + Self.scanWidth, hosts.count)]
            await withTaskGroup(of: NearbyDevice?.self) { group in
                for host in slice { group.addTask { await probe(host, port: port, transport: transport) } }
                for await device in group { if let device { found.append(device) } }
            }
        }
        return found
    }

    private func probe(_ host: String, port: Int, transport: TransportProtocol) async -> NearbyDevice? {
        var components = URLComponents()
        components.scheme = transport.rawValue
        components.host = host
        components.port = port
        components.path = LocalSendProtocol.apiPath + "/register"
        guard let url = components.url, let answer = await post(to: url, expecting: nil, timeout: Self.scanTimeout),
              let info = try? JSONDecoder().decode(DeviceInfo.self, from: answer.data) else { return nil }
        let fingerprint = answer.certificateFingerprint ?? info.fingerprint
        guard fingerprint != sender.fingerprint else { return nil }
        return NearbyDevice(info: info.with(fingerprint: fingerprint, port: port, transport: transport), host: host)
    }

    private func post(to url: URL, expecting fingerprint: String?, timeout: TimeInterval) async -> (data: Data, certificateFingerprint: String?)? {
        var request = URLRequest(url: url, timeoutInterval: timeout)
        request.httpMethod = "POST"
        request.setValue(HTTPResponse.jsonType, forHTTPHeaderField: "Content-Type")
        guard let body = try? JSONEncoder().encode(sender) else { return nil }
        request.httpBody = body
        let trust = CertificateRecorder(expectedFingerprint: fingerprint)
        let session = URLSession(configuration: .ephemeral, delegate: trust, delegateQueue: nil)
        defer { session.finishTasksAndInvalidate() }
        guard let (data, response) = try? await session.data(for: request),
              (response as? HTTPURLResponse)?.statusCode == HTTPStatus.ok else { return nil }
        return (data, trust.seenFingerprint)
    }
}

/// Accepts a self-signed certificate, pinned when its fingerprint is known, recorded otherwise
/// so the device found by a scan can be pinned from then on.
nonisolated final class CertificateRecorder: NSObject, URLSessionDelegate, @unchecked Sendable {
    private let expectedFingerprint: String?
    private let lock = NSLock()
    private var recorded: String?

    init(expectedFingerprint: String?) {
        self.expectedFingerprint = expectedFingerprint
    }

    var seenFingerprint: String? { lock.withLock { recorded } }

    func urlSession(
        _ session: URLSession, didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        guard let trust = challenge.protectionSpace.serverTrust,
              let leaf = (SecTrustCopyCertificateChain(trust) as? [SecCertificate])?.first else {
            return (.performDefaultHandling, nil)
        }
        let fingerprint = TLSIdentityStore.fingerprint(of: SecCertificateCopyData(leaf) as Data)
        if let expectedFingerprint, fingerprint.caseInsensitiveCompare(expectedFingerprint) != .orderedSame {
            return (.cancelAuthenticationChallenge, nil)
        }
        lock.withLock { recorded = fingerprint }
        return (.useCredential, URLCredential(trust: trust))
    }
}

extension DeviceInfo {
    /// The same device, with what the scan learned about how to reach it.
    nonisolated func with(fingerprint: String, port: Int, transport: TransportProtocol) -> DeviceInfo {
        DeviceInfo(alias: alias, version: version, deviceModel: deviceModel, deviceType: deviceType, fingerprint: fingerprint,
                   port: port, protocol: transport, download: download, announce: nil)
    }
}
