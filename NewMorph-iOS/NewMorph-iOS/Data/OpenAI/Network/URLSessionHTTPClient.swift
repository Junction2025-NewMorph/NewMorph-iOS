//
//  URLSessionHTTPClient.swift
//  NewMorph-iOS
//
//  Created by OneThing on 8/23/25.
//
import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    private let config: NetworkConfig
    private let session: URLSession

    public init(config: NetworkConfig) {
        self.config = config
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = config.timeout
        self.session = URLSession(configuration: sessionConfig)
    }

    public func postJSON<Request: Encodable, Response: Decodable>(
        path: String,
        body: Request
    ) async throws -> Response {
        var request = URLRequest(
            url: config.baseURL.appendingPathComponent(path)
        )
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(
            "Bearer \(config.apiKey)",
            forHTTPHeaderField: "Authorization"
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, resp) = try await session.data(for: request)
        guard let http = resp as? HTTPURLResponse,
            (200..<300).contains(http.statusCode)
        else {
            throw NSError(
                domain: "HTTPError",
                code: (resp as? HTTPURLResponse)?.statusCode ?? -1,
                userInfo: [
                    "response": resp,
                    "body": String(data: data, encoding: .utf8) ?? "",
                ]
            )
        }
        return try JSONDecoder().decode(Response.self, from: data)
    }
}
