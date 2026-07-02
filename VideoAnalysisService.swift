import Foundation
import AVFoundation
import UIKit

struct VideoAnalysisResult: Codable {
    let tips: [String]
}

final class VideoAnalysisService {
    private let endpoint = Config.baseURL.appendingPathComponent("api/video-analysis")

    func analyse(videoURL: URL, stroke: Stroke) async throws -> [String] {
        let frames = try await extractFrames(from: videoURL, count: 6)
        let base64Frames = frames.compactMap { $0.jpegData(compressionQuality: 0.5)?.base64EncodedString() }

        guard !base64Frames.isEmpty else {
            throw URLError(.cannotDecodeContentData)
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "stroke": stroke.rawValue,
            "frames": base64Frames,
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let decoded = try JSONDecoder().decode(VideoAnalysisResult.self, from: data)
        return decoded.tips
    }

    // Pulls a set number of frames, spread evenly across the clip.
    private func extractFrames(from url: URL, count: Int) async throws -> [UIImage] {
        let asset = AVURLAsset(url: url)
        let duration = try await asset.load(.duration)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true

        var images: [UIImage] = []
        for i in 0..<count {
            let fraction = Double(i) / Double(max(count - 1, 1))
            let time = CMTime(seconds: duration.seconds * fraction, preferredTimescale: 600)
            if let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) {
                images.append(UIImage(cgImage: cgImage))
            }
        }
        return images
    }
}
