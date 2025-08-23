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
    struct TextFormat: Encodable {
        let type: String  // "json_schema" 
        let name: String? // Required for json_schema
        let schema: JSONSchema.Schema? // Direct schema, not nested in json_schema
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
    struct Text: Encodable {
        let format: TextFormat
    }

    let model: String
    let input: [Input]
    let text: Text
    let store: Bool?
}

// MARK: - Success Response

struct ResponsesSuccess: Decodable {
    let id: String
    let object: String
    let created_at: Int
    let status: String
    let model: String
    let output: [OutputMessage]
    
    struct OutputMessage: Decodable {
        let type: String  // "message"
        let id: String
        let status: String
        let role: String  // "assistant"
        let content: [Content]
    }
    
    struct Content: Decodable {
        let type: String  // "output_text"
        let text: String
    }
}

// MARK: - Domain decoding target

public struct EnglishVariants: Decodable {
    public let natural: String
    public let friend: String
    public let family: String
    public let third: String  // (auto) formal or meme/humor
}
