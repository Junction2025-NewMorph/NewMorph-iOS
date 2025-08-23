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
            response_format: .init(
                type: "json_schema",
                json_schema: EnglishStylePromptBuilder.schema()
            )
        )

        // POST /v1/responses
        let res: ResponsesSuccess = try await http.postJSON(
            path: "/v1/responses",
            body: req
        )

        // Prefer output_text; fallback to output[].content[].text
        let jsonString =
            res.output_text
            ?? res.output?
            .compactMap { $0.content.first?.text }
            .joined(separator: "\n")

        guard let json = jsonString, let data = json.data(using: .utf8) else {
            throw NSError(
                domain: "OpenAI",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "No JSON in response"]
            )
        }

        return try JSONDecoder().decode(EnglishVariants.self, from: data)
    }
}
