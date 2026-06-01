import SwiftUI
@preconcurrency import Vision

/// Actor executor is off the main thread - Vision's blocking perform() won't stall UI.
actor OCRService {
  static let shared = OCRService()
  private init() {}

  func recognizeText(in imageData: Data) async throws -> OCRResult {
    // CGImageSource is thread-safe and @MainActor-free. UIImage is @MainActor in
    // newer SDKs, so using it here (or inside Task.detached) triggers
    // "unsafeForcedSync called from Swift Concurrent context" at runtime.
    guard
      let source = CGImageSourceCreateWithData(imageData as CFData, nil),
      let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)
    else {
      throw OCRError.invalidImage
    }

    // Vision's synchronous perform() runs directly on this actor's executor,
    // which is already a background thread — no Task.detached needed.
    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true

    // Enable multilingual recognition so screenshots in non-English languages
    // are fully extracted. On iOS 16+ Vision can detect the language automatically;
    // on older OS versions we supply a filtered fallback list so we only pass
    // languages that the current revision actually supports (avoids crashes).
    if #available(iOS 16.0, *) {
      request.automaticallyDetectsLanguage = true
    } else {
      let preferredLanguages = [
        "en-US", "es-ES", "fr-FR", "de-DE", "it-IT",
        "pt-BR", "ja-JP", "ko-KR", "zh-Hans", "zh-Hant", "th-TH",
      ]
      let supported =
        (try? VNRecognizeTextRequest.supportedRecognitionLanguages(
          for: request.recognitionLevel,
          revision: request.revision
        )) ?? ["en-US"]
      request.recognitionLanguages = preferredLanguages.filter { supported.contains($0) }
    }

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
  }
}

enum OCRError: LocalizedError {
  case invalidImage

  var errorDescription: String? {
    "Cannot create CGImage from provided data"
  }
}
