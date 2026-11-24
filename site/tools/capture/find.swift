import AppKit
import Vision

// Prints where a text sits on a capture, in device points (iPhone 17 Pro: 402 x 874), so a
// tap can aim at it: `find.swift <png> <text>` prints « x y » of the first line containing it.
let arguments = CommandLine.arguments
let image = NSImage(contentsOfFile: arguments[1])!
var rect = CGRect(origin: .zero, size: image.size)
let cgImage = image.cgImage(forProposedRect: &rect, context: nil, hints: nil)!
let request = VNRecognizeTextRequest()
request.recognitionLevel = .accurate
try VNImageRequestHandler(cgImage: cgImage).perform([request])
let pointWidth = 402.0, pointHeight = 874.0
for observation in request.results ?? [] {
    guard let text = observation.topCandidates(1).first?.string, text.contains(arguments[2]) else { continue }
    let box = observation.boundingBox
    print(Int(box.midX * pointWidth), Int((1 - box.midY) * pointHeight))
    break
}
