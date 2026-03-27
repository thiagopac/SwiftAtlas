import Foundation

enum NetworkError: Error {
    case invalidResponse
}

struct ContentAPI {

    static func fetchContent(
        onProgress: @escaping @MainActor (_ progress: Double?) async -> Void = { _ in }
    ) async throws -> RemoteContent {
        var lastError: Error?

        for attempt in 0..<3 {
            do {
                return try await fetchContentOnce(onProgress: onProgress)
            } catch {
                lastError = error

                guard attempt < 2, shouldRetry(error) else {
                    throw error
                }

                try await Task.sleep(for: .milliseconds(700))
            }
        }

        throw lastError ?? NetworkError.invalidResponse
    }

    private static func fetchContentOnce(
        onProgress: @escaping @MainActor (_ progress: Double?) async -> Void
    ) async throws -> RemoteContent {
        let url = URL(string: "https://cdn.jsdelivr.net/gh/thiagopac/swift-atlas-content/content.json")!
        let (bytes, response) = try await URLSession.shared.bytes(from: url)

        guard let http = response as? HTTPURLResponse,
              200...299 ~= http.statusCode else {
            throw NetworkError.invalidResponse
        }

        let expectedLength = response.expectedContentLength
        var receivedLength = Int64(0)
        var data = Data()

        if expectedLength > 0 {
            await onProgress(0)
        } else {
            await onProgress(nil)
        }

        for try await byte in bytes {
            data.append(contentsOf: [byte])
            receivedLength += 1

            guard expectedLength > 0 else { continue }

            let progress = min(Double(receivedLength) / Double(expectedLength), 1)
            await onProgress(progress)
        }

        if expectedLength > 0 {
            await onProgress(1)
        }

        return try JSONDecoder().decode(RemoteContent.self, from: data)
    }

    private static func shouldRetry(_ error: Error) -> Bool {
        guard let urlError = error as? URLError else {
            return false
        }

        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost, .cannotFindHost, .cannotConnectToHost, .timedOut:
            return true
        default:
            return false
        }
    }
}
