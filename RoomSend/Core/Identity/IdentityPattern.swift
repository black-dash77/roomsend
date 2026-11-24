import Foundation

/// The avatar of a device, computed from its fingerprint alone, the way MetaMask computes an
/// account's avatar from its address: the same device always gets the same picture, and two
/// devices almost never share one. Pure data; `IdentityAvatar` draws it.
nonisolated struct IdentityPattern: Equatable, Sendable {
    nonisolated struct Shape: Equatable, Sendable {
        let colorIndex: Int
        /// Degrees.
        let rotation: Double
        /// Offsets from the center, in avatar diameters.
        let offsetX: Double
        let offsetY: Double
    }

    let baseColorIndex: Int
    let shapes: [Shape]

    /// Side of each square, in avatar diameters: smaller than the circle, so the base color
    /// stays visible between them.
    static let shapeScale = 0.78

    private static let shapeCount = 3
    /// Each square is pushed out from the center by this share of the diameter, in a direction
    /// of its own, so every color keeps a visible field instead of a thin wedge.
    private static let offsetRange = 0.3...0.42
    private static let fullTurn = 360.0

    init(fingerprint: String) {
        var generator = SeededGenerator(seed: Self.hash(fingerprint))
        var indices = Array(IdentityPalette.hexes.indices)
        indices.shuffle(using: &generator)
        baseColorIndex = indices[0]
        let start = Double.random(in: 0..<Self.fullTurn, using: &generator)
        shapes = indices.dropFirst().prefix(Self.shapeCount).enumerated().map { order, index in
            let direction = (start + Double(order) * Self.fullTurn / Double(Self.shapeCount)) * .pi / 180
            let distance = Double.random(in: Self.offsetRange, using: &generator)
            return Shape(
                colorIndex: index,
                rotation: Double.random(in: 0..<Self.fullTurn, using: &generator),
                offsetX: cos(direction) * distance,
                offsetY: sin(direction) * distance
            )
        }
    }

    /// FNV-1a, 64 bits: stable across launches and devices, unlike `hashValue`.
    private static func hash(_ text: String) -> UInt64 {
        let offsetBasis: UInt64 = 0xCBF2_9CE4_8422_2325
        let prime: UInt64 = 0x0000_0100_0000_01B3
        return text.utf8.reduce(offsetBasis) { ($0 ^ UInt64($1)) &* prime }
    }
}

/// SplitMix64: a small, fast generator that always gives the same sequence for the same seed.
nonisolated struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var value = state
        value = (value ^ (value >> 30)) &* 0xBF58_476D_1CE4_E5B9
        value = (value ^ (value >> 27)) &* 0x94D0_49BB_1331_11EB
        return value ^ (value >> 31)
    }
}
