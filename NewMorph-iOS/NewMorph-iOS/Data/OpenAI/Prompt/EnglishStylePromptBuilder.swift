//
//  EnglishStylePromptBuilder.swift
//  NewMorph-iOS
//
//  Created by OneThing on 8/23/25.
//

import Foundation

enum EnglishStylePromptBuilder {
    static func system() -> String {
        """
        You rewrite mixed Korean+English sentences into correct English.
        Return exactly three style variants:
        1) Super casual DM for close friends (Gen Z slang okay; short; emoji optional)
        2) Warm casual for family/friends (no slang; kind tone)
        3) YOU decide:
           - If the sentence is suitable for professional use, return a polished company/formal version.
           - If the sentence is better expressed humorously, return a meme/humor version.
        Output MUST be valid JSON with keys: friend, family, third.
        No extra text outside JSON.
        """
    }

    static func user(_ mixed: String) -> String {
        """
        Original: \(mixed)
        Produce 3 variants: friend, family, third (third is either company/formal OR meme/humor).
        """
    }

    static func schema() -> ResponsesRequest.JSONSchema {
        .init(
            name: "EnglishVariants",
            schema: .init(
                type: "object",
                properties: [
                    "friend": .init(
                        type: "string",
                        description: "1) Super casual DM, MZ style"
                    ),
                    "family": .init(
                        type: "string",
                        description: "2) Warm casual for family/friends"
                    ),
                    "third": .init(
                        type: "string",
                        description: """
                            3) GPT decides: company/formal if professional; else meme/humor if casual/funny fits better.
                            """
                    ),
                ],
                required: ["friend", "family", "third"],
                additionalProperties: false
            )
        )
    }
}
