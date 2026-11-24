import CryptoKit
import Foundation
import OSLog
import Security
import SwiftASN1
import X509

/// The TLS identity of this device: a self-signed P-256 certificate made once, kept in the
/// keychain with its key. Its SHA-256 is the fingerprint LocalSend announces in HTTPS mode
/// (protocol v2.2, section 2), so a sender can check it is talking to this device.
nonisolated struct TLSIdentity: @unchecked Sendable {
    let identity: SecIdentity
    let fingerprint: String
}

nonisolated enum TLSIdentityStore {
    private static let label = "app.roomsend.ios.tls"
    private static let commonName = "RoomSend"
    private static let validity: TimeInterval = 10 * 365 * 24 * 3600
    private static let clockSkew: TimeInterval = 24 * 3600

    /// The stored identity, or a new one; nil only if the keychain refuses both.
    static func loadOrCreate() -> TLSIdentity? {
        if let stored = load() { return stored }
        do {
            try create()
        } catch {
            Log.server.error("TLS identity not created: \(error.localizedDescription)")
            return nil
        }
        return load()
    }

    private static func load() -> TLSIdentity? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassIdentity,
            kSecAttrLabel as String: label,
            kSecReturnRef as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess, let item,
              CFGetTypeID(item) == SecIdentityGetTypeID() else { return nil }
        let identity = item as! SecIdentity // swiftlint:disable:this force_cast (CF type checked above)
        var certificate: SecCertificate?
        guard SecIdentityCopyCertificate(identity, &certificate) == errSecSuccess, let certificate else { return nil }
        return TLSIdentity(identity: identity, fingerprint: fingerprint(of: SecCertificateCopyData(certificate) as Data))
    }

    private static func create() throws {
        let key = P256.Signing.PrivateKey()
        let der = try makeCertificate(signedWith: key)
        try store(key: key)
        try store(certificate: der)
    }

    private static func makeCertificate(signedWith key: P256.Signing.PrivateKey) throws -> Data {
        let name = try DistinguishedName { CommonName(commonName) }
        let now = Date()
        let certificate = try Certificate(
            version: .v3,
            serialNumber: Certificate.SerialNumber(),
            publicKey: Certificate.PublicKey(key.publicKey),
            notValidBefore: now.addingTimeInterval(-clockSkew),
            notValidAfter: now.addingTimeInterval(validity),
            issuer: name,
            subject: name,
            signatureAlgorithm: .ecdsaWithSHA256,
            extensions: try Certificate.Extensions { Critical(BasicConstraints.notCertificateAuthority) },
            issuerPrivateKey: Certificate.PrivateKey(key)
        )
        var serializer = DER.Serializer()
        try serializer.serialize(certificate)
        return Data(serializer.serializedBytes)
    }

    private static func store(key: P256.Signing.PrivateKey) throws {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
        ]
        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(key.x963Representation as CFData, attributes as CFDictionary, &error) else {
            throw error.map { $0.takeRetainedValue() as Error } ?? KeychainError.status(errSecParam)
        }
        try add([kSecClass as String: kSecClassKey, kSecValueRef as String: secKey, kSecAttrLabel as String: label])
    }

    private static func store(certificate der: Data) throws {
        guard let certificate = SecCertificateCreateWithData(nil, der as CFData) else { throw KeychainError.status(errSecParam) }
        try add([kSecClass as String: kSecClassCertificate, kSecValueRef as String: certificate, kSecAttrLabel as String: label])
    }

    private static func add(_ attributes: [String: Any]) throws {
        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess || status == errSecDuplicateItem else { throw KeychainError.status(status) }
    }

    static func fingerprint(of der: Data) -> String {
        SHA256.hash(data: der).map { String(format: "%02x", $0) }.joined()
    }
}

nonisolated enum KeychainError: Error {
    case status(OSStatus)
}
