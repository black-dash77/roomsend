import Foundation

/// Prints, as JSON, the avatar pattern the app computes for each fingerprint given in
/// argument. Compiled with the app's own `IdentityPattern.swift` and `Palette.swift`, so the
/// site draws exactly the avatars the captures show. Run by `site/tools/avatars/run.sh`.
struct Square: Encodable {
    let color: String
    let rotation: Double
    let x: Double
    let y: Double
}

struct Avatar: Encodable {
    let fingerprint: String
    let base: String
    let scale: Double
    let squares: [Square]
}

func hex(_ index: Int) -> String {
    String(format: "#%06X", IdentityPalette.hexes[index % IdentityPalette.hexes.count])
}

let avatars = CommandLine.arguments.dropFirst().map { fingerprint in
    let pattern = IdentityPattern(fingerprint: fingerprint)
    return Avatar(
        fingerprint: fingerprint,
        base: hex(pattern.baseColorIndex),
        scale: IdentityPattern.shapeScale,
        squares: pattern.shapes.map { Square(color: hex($0.colorIndex), rotation: $0.rotation, x: $0.offsetX, y: $0.offsetY) }
    )
}
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
print(String(decoding: try encoder.encode(avatars), as: UTF8.self))
