import ImageIO
import PhotosUI
import SwiftUI
import UIKit
import Vision
import KiraCore

/// Reads the text in an image on the iPhone with Vision, as lines in reading order.
enum TextRecognizer {
    static func lines(in image: CGImage, orientation: CGImagePropertyOrientation = .up) async throws -> [String] {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let request = VNRecognizeTextRequest()
                request.recognitionLevel = .accurate
                // Correction "fixes" merchant names and amounts, so it stays off.
                request.usesLanguageCorrection = false
                let handler = VNImageRequestHandler(cgImage: image, orientation: orientation, options: [:])
                do {
                    try handler.perform([request])
                    continuation.resume(returning: rows(from: request.results ?? []))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Joins pieces of text that sit on the same visual row ("7-Eleven" on the left, "-6.80" on the right),
    /// then returns the rows top to bottom.
    static func rows(from observations: [VNRecognizedTextObservation]) -> [String] {
        let pieces: [(text: String, box: CGRect)] = observations.compactMap { observation in
            guard let candidate = observation.topCandidates(1).first else { return nil }
            return (candidate.string, observation.boundingBox)
        }
        // Vision's coordinates start at the bottom left, so a higher midY is nearer the top.
        let sorted = pieces.sorted { $0.box.midY > $1.box.midY }
        var rows: [[(text: String, box: CGRect)]] = []
        for piece in sorted {
            if let last = rows.last?.first,
               abs(last.box.midY - piece.box.midY) < min(last.box.height, piece.box.height) * 0.5 {
                rows[rows.count - 1].append(piece)
            } else {
                rows.append([piece])
            }
        }
        return rows.map { row in
            row.sorted { $0.box.minX < $1.box.minX }.map(\.text).joined(separator: "  ")
        }
    }
}

/// Turns a picked screenshot into rows to check: load, read the text, then KiraCore's screenshot parser.
enum ScreenshotReader {
    static func read(_ item: PhotosPickerItem, existing: [LedgerItem]) async -> ScreenshotBatch? {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data),
              let cgImage = image.cgImage else { return nil }
        guard let lines = try? await TextRecognizer.lines(in: cgImage, orientation: CGImagePropertyOrientation(image.imageOrientation)) else {
            return nil
        }
        let drafts = ScreenshotParser().parse(lines: lines, now: Date(), existing: existing)
        return ScreenshotBatch(image: image, drafts: drafts)
    }
}

extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
