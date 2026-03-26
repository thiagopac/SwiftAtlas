import Foundation

enum NetworkError: Error {
    case invalidResponse
}

struct ContentAPI {

    static func fetchContent() async throws -> RemoteContent {
        let url = URL(string: "https://cdn.jsdelivr.net/gh/thiagopac/swift-atlas-content/content.json")!
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse,
              200...299 ~= http.statusCode else {
            throw NetworkError.invalidResponse
        }

        return try JSONDecoder().decode(RemoteContent.self, from: data)
    }
}
