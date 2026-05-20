import SwiftUI
@preconcurrency import Vision

/// Actor executor is off the main thread — Vision's blocking perform() won't stall UI.
actor OCRService {
  static let shared = OCRService()
  private init() {}

  func recognizeText(in imageData: Data) async throws -> OCRResult {
    // Detach so Vision's synchronous perform() runs on a thread-pool thread.
    try await Task.detached(priority: .userInitiated) {
      guard let cgImage = UIImage(data: imageData)?.cgImage else {
        throw OCRError.invalidImage
      }

      // No completion-handler API — read .results directly after perform() returns.
      // This avoids mutating captured vars inside a @Sendable closure.
      let request = VNRecognizeTextRequest()
      request.recognitionLevel = .accurate
      request.usesLanguageCorrection = true
      request.recognitionLanguages = ["en-US"]

      let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
      try handler.perform([request])

      let observations = request.results ?? []
      let text =
        observations
        .compactMap { $0.topCandidates(1).first }
        .map(\.string)
        .joined(separator: "\n")
      let avgConfidence =
        observations
        .compactMap { $0.topCandidates(1).first?.confidence }
        .reduce(0, +) / Float(max(observations.count, 1))

      return OCRResult(text: text, confidence: avgConfidence)
    }.value
  }
}

enum OCRError: LocalizedError {
  case invalidImage

  var errorDescription: String? {
    "Cannot create CGImage from provided data"
  }
}
