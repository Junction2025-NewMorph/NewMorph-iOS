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
    
    private func logRequest(_ request: URLRequest, body: Data?) {
        print("🌐 API Request:")
        print("URL: \(request.url?.absoluteString ?? "Unknown")")
        print("Method: \(request.httpMethod ?? "Unknown")")
        print("Headers:")
        request.allHTTPHeaderFields?.forEach { key, value in
            let logValue = key == "Authorization" ? "Bearer ***" : value
            print("  \(key): \(logValue)")
        }
        if let body = body, let bodyString = String(data: body, encoding: .utf8) {
            print("Body:")
            print(bodyString)
        }
        print("---")
    }
    
    private func logResponse(_ response: URLResponse?, data: Data?, error: Error?) {
        print("📡 API Response:")
        if let httpResponse = response as? HTTPURLResponse {
            print("Status: \(httpResponse.statusCode)")
        }
        if let error = error {
            print("Error: \(error)")
        }
        if let data = data, let responseString = String(data: data, encoding: .utf8) {
            print("Data: \(responseString)")
        }
        print("---")
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
        
        // 요청 로그
        logRequest(request, body: request.httpBody)

        do {
            let (data, resp) = try await session.data(for: request)
            
            // 응답 로그
            logResponse(resp, data: data, error: nil)
            
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
        } catch {
            // 에러 로그
            logResponse(nil, data: nil, error: error)
            throw error
        }
    }
}
