#!/usr/bin/env swift

import AppKit
import Foundation

func fail(_ message: String) -> Never {
  fputs("Error: \(message)\n", stderr)
  exit(1)
}

guard CommandLine.arguments.count == 2 else {
  fail("Usage: generate_default_icon.swift <output_png_path>")
}

let outputPath = CommandLine.arguments[1]
let outputURL = URL(fileURLWithPath: outputPath)
let parentURL = outputURL.deletingLastPathComponent()

let fileManager = FileManager.default

if !fileManager.fileExists(atPath: parentURL.path) {
  do {
    try fileManager.createDirectory(at: parentURL, withIntermediateDirectories: true)
  } catch {
    fail("Unable to create output directory: \(error.localizedDescription)")
  }
}

let canvasSize = NSSize(width: 1024, height: 1024)
let image = NSImage(size: canvasSize)

image.lockFocus()

let fullRect = NSRect(origin: .zero, size: canvasSize)

NSColor(calibratedRed: 0.02, green: 0.03, blue: 0.05, alpha: 1.0).setFill()
fullRect.fill()

let outerInset: CGFloat = 44
let outerRect = fullRect.insetBy(dx: outerInset, dy: outerInset)
let outerPath = NSBezierPath(roundedRect: outerRect, xRadius: 170, yRadius: 170)

let shellGradient = NSGradient(colorsAndLocations:
  NSColor(calibratedRed: 0.07, green: 0.1, blue: 0.15, alpha: 1.0), 0.0,
  NSColor(calibratedRed: 0.04, green: 0.07, blue: 0.11, alpha: 1.0), 0.35,
  NSColor(calibratedRed: 0.01, green: 0.55, blue: 0.36, alpha: 1.0), 1.0
)

shellGradient?.draw(in: outerPath, angle: -90)

NSColor(calibratedRed: 0.0, green: 0.9, blue: 0.6, alpha: 0.28).setStroke()
outerPath.lineWidth = 14
outerPath.stroke()

let terminalInset: CGFloat = 124
let terminalRect = fullRect.insetBy(dx: terminalInset, dy: terminalInset)
let terminalPath = NSBezierPath(roundedRect: terminalRect, xRadius: 74, yRadius: 74)

NSColor(calibratedRed: 0.01, green: 0.02, blue: 0.03, alpha: 0.85).setFill()
terminalPath.fill()

NSColor(calibratedRed: 0.0, green: 0.95, blue: 0.65, alpha: 0.35).setStroke()
terminalPath.lineWidth = 6
terminalPath.stroke()

let prompt = ">_"
let promptFont = NSFont(name: "Menlo-Bold", size: 268) ?? NSFont.monospacedSystemFont(ofSize: 268, weight: .bold)
let promptAttributes: [NSAttributedString.Key: Any] = [
  .font: promptFont,
  .foregroundColor: NSColor(calibratedRed: 0.92, green: 0.99, blue: 0.96, alpha: 1.0),
]

let promptSize = prompt.size(withAttributes: promptAttributes)
let promptOrigin = NSPoint(
  x: terminalRect.midX - (promptSize.width / 2),
  y: terminalRect.midY - (promptSize.height / 2) + 20
)
prompt.draw(at: promptOrigin, withAttributes: promptAttributes)

image.unlockFocus()

guard let tiffData = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiffData),
      let pngData = bitmap.representation(using: .png, properties: [.compressionFactor: 1.0]) else {
  fail("Failed to generate PNG data")
}

do {
  try pngData.write(to: outputURL)
} catch {
  fail("Unable to write PNG file: \(error.localizedDescription)")
}

print("Generated default icon at \(outputURL.path)")
