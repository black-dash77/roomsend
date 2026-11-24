import Foundation
import Observation

/// How this device receives: ask each time or accept at once, a PIN or not, photos to Photos.
@Observable
final class ReceiveSettings {
    var acceptsAutomatically: Bool {
        didSet { defaults.set(acceptsAutomatically, forKey: Keys.quickSave) }
    }
    var requiresPin: Bool {
        didSet { defaults.set(requiresPin, forKey: Keys.requiresPin) }
    }
    var pin: String {
        didSet { defaults.set(pin, forKey: Keys.pin) }
    }
    var savesMediaToPhotos: Bool {
        didSet { defaults.set(savesMediaToPhotos, forKey: Keys.photos) }
    }

    static let pinLength = 6

    private let defaults: UserDefaults

    private enum Keys {
        static let quickSave = "receive.quickSave"
        static let requiresPin = "receive.requiresPin"
        static let pin = "receive.pin"
        static let photos = "receive.photos"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        acceptsAutomatically = defaults.bool(forKey: Keys.quickSave)
        requiresPin = defaults.bool(forKey: Keys.requiresPin)
        pin = defaults.string(forKey: Keys.pin) ?? Self.randomPin()
        savesMediaToPhotos = defaults.object(forKey: Keys.photos) as? Bool ?? true
    }

    /// True when no PIN is asked, or when the given one matches.
    func accepts(pin candidate: String?) -> Bool {
        !requiresPin || candidate == pin
    }

    private static func randomPin() -> String {
        (0..<pinLength).map { _ in String(Int.random(in: 0...9)) }.joined()
    }
}
