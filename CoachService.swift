import Foundation

/*
 Your old web build called the Anthropic API straight from the browser, with the API key
 sitting in the JavaScript. On the App Store, that same approach would put your key inside
 the app binary, where anyone could pull it out and run up charges on your account.

 The fix is a small backend of your own (see the swim-ai-backend folder) that holds the
 key and forwards requests to Claude. This app talks to that backend, never to Anthropic
 directly.
*/

struct CoachTip: Codable {
    let tip: String
}

final class CoachService {
    private let endpoint = Config.baseURL.appendingPathComponent("api/coach-tip")

    func fetchTip(forStroke stroke: Stroke, recentPace: Double?) async throws -> String {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "stroke": stroke.rawValue,
            "recentPace": recentPace as Any
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let decoded = try JSONDecoder().decode(CoachTip.self, from: data)
        return decoded.tip
    }
}
