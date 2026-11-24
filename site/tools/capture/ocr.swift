import AppKit
import Vision

// Prints the text Vision reads in a band of a capture: `ocr.swift <png> <top> <bottom>` with the
// band in fractions of the height, optionally `<left> <right>` in fractions of the width. Used to note which recipient each carousel capture centres.
let arguments = CommandLine.arguments
let image = NSImage(contentsOfFile: arguments[1])!
var rect = CGRect(origin: .zero, size: image.size)
let cgImage = image.cgImage(forProposedRect: &rect, context: nil, hints: nil)!
let top = Double(arguments[2])!, bottom = Double(arguments[3])!
let request = VNRecognizeTextRequest()
request.recognitionLevel = .accurate
let left = arguments.count > 4 ? Double(arguments[4])! : 0.3
let right = arguments.count > 5 ? Double(arguments[5])! : 0.7
request.regionOfInterest = CGRect(x: left, y: 1 - bottom, width: right - left, height: bottom - top)
try VNImageRequestHandler(cgImage: cgImage).perform([request])
let lines = (request.results ?? []).compactMap { $0.topCandidates(1).first?.string }
print(lines.joined(separator: " | "))
