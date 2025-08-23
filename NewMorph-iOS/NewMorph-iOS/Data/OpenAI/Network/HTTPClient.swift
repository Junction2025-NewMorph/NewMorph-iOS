//
//  HTTPClient.swift
//  NewMorph-iOS
//
//  Created by OneThing on 8/23/25.
//

import Foundation

public protocol HTTPClient {
    func postJSON<Request: Encodable, Response: Decodable>(
        path: String,
        body: Request
    ) async throws -> Response
}
