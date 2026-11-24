import CryptoKit
import Foundation

/// Accepts a receiver's self-signed certificate only if its SHA-256 is the fingerprint the
/// receiver announced (protocol v2.2, section 2): the certificate is pinned, never trusted
/// blindly.
nonisolated final class FingerprintTrust: NSObject, URLSessionDelegate, Sendable {
    private let expectedFingerprint: String

    init(expectedFingerprint: String) {
        self.expectedFingerprint = expectedFingerprint
    }

    func urlSession(
        _ session: URLSession, didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let trust = challenge.protectionSpace.serverTrust,
              let leaf = (SecTrustCopyCertificateChain(trust) as? [SecCertificate])?.first
        else { return (.performDefaultHandling, nil) }
        guard Self.fingerprint(of: leaf).caseInsensitiveCompare(expectedFingerprint) == .orderedSame else {
            Log.transfer.error("Certificate does not match the announced fingerprint; transfer refused.")
            return (.cancelAuthenticationChallenge, nil)
        }
        return (.useCredential, URLCredential(trust: trust))
    }

    private static func fingerprint(of certificate: SecCertificate) -> String {
        let der = SecCertificateCopyData(certificate) as Data
        return SHA256.hash(data: der).map { String(format: "%02x", $0) }.joined()
    }
}
