//
//  ResponsesRequest.swift
//  NewMorph-iOS
//
//  Created by OneThing on 8/23/25.
//

import Foundation

// MARK: - Request (Responses API)

struct ResponsesRequest: Encodable {
    struct Input: Encodable {
        let role: String  // "system", "user"
        let content: String
    }
    struct ResponseFormat: Encodable {
        let type: String  // "json_schema"
        let json_schema: JSONSchema
    }
    struct JSONSchema: Encodable {
        let name: String
        let schema: Schema
        struct Schema: Encodable {
            struct Property: Encodable {
                let type: String
                let description: String?
            }
            let type: String  // "object"
            let properties: [String: Property]
            let required: [String]
            let additionalProperties: Bool
        }
    }

    let model: String
    let input: [Input]
    let response_format: ResponseFormat
}

// MARK: - Success Response

struct ResponsesSuccess: Decodable {
    let output_text: String?  // some models/SDKs expose concatenated text here
    struct OutputItem: Decodable {
        struct Content: Decodable {
            let type: String
            let text: String?
        }
        let content: [Content]
    }
    let output: [OutputItem]?
}

// MARK: - Domain decoding target

public struct EnglishVariants: Decodable {
    public let friend: String
    public let family: String
    public let third: String  // (auto) formal or meme/humor
}
