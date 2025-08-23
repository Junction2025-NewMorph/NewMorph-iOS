//
//  OpenAIResponsesClient.swift
//  NewMorph-iOS
//
//  Created by OneThing on 8/23/25.
//

import Foundation

public final class OpenAIResponsesClient: OpenAIClient {
    private let http: HTTPClient
    private let model: String

    public init(http: HTTPClient, model: String) {
        self.http = http
        self.model = model
    }

    public func generateEnglishVariants(mixedText: String) async throws
        -> EnglishVariants
    {
        let req = ResponsesRequest(
            model: model,
            input: [
                .init(
                    role: "system",
                    content: EnglishStylePromptBuilder.system()
                ),
                .init(
                    role: "user",
                    content: EnglishStylePromptBuilder.user(mixedText)
                ),
            ],
            text: .init(
                format: .init(
                    type: "json_schema",
                    name: "EnglishVariants",
                    schema: EnglishStylePromptBuilder.schema().schema
                )
            ),
            store: true
        )

        // POST /v1/responses
        let res: ResponsesSuccess = try await http.postJSON(
            path: "/v1/responses",
            body: req
        )

        // Extract JSON from new response format
        guard let firstOutput = res.output.first,
              let firstContent = firstOutput.content.first,
              firstContent.type == "output_text" else {
            throw NSError(
                domain: "OpenAI",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "No output content in response"]
            )
        }
        
        let jsonString = firstContent.text
        guard let data = jsonString.data(using: .utf8) else {
            throw NSError(
                domain: "OpenAI",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Failed to convert JSON string to data"]
            )
        }

        return try JSONDecoder().decode(EnglishVariants.self, from: data)
    }
}
