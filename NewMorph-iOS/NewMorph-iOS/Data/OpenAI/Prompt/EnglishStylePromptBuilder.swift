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
        Rewrite mixed Korean+English into natural English, then output 3 tone variants of the SAME meaning.

        JSON keys: natural, friend, family, third

        Rules:
        - Preserve the user’s meaning strictly. Do NOT invent, infer, or add details.
        - natural: rewrite as one polished English sentence.
        - friend: same meaning, casual MZ DM tone (light slang ok: lol, omg; emojis optional).
        - family: same meaning, warm and simple tone (no slang).
        - third: YOU decide:
            * If input is neutral/task/professional → formal/company tone.
            * If input is personal/casual/spicy/fandom → playful meme tone.
        - Safety: never output hate, discrimination, sexually explicit content, or private data.
        - English only; Romanize Korean words (e.g., tteokbokki, omurice).
        - Output valid JSON only.
        """
    }

    static func user(_ mixed: String) -> String {
        """
        Original: \(mixed)
        Step 1: natural (one polished sentence).
        Step 2: friend, family, third (same meaning only, different tones).
        """
    }

    static func schema() -> ResponsesRequest.JSONSchema {
        .init(
            name: "EnglishVariants",
            schema: .init(
                type: "object",
                properties: [
                    "natural": .init(
                        type: "string",
                        description: "One polished English sentence"
                    ),
                    "friend": .init(
                        type: "string",
                        description: "Same meaning, casual MZ DM tone"
                    ),
                    "family": .init(
                        type: "string",
                        description: "Same meaning, warm simple tone"
                    ),
                    "third": .init(
                        type: "string",
                        description:
                            "Same meaning, either formal/company OR meme tone depending on context"
                    ),
                ],
                required: ["natural", "friend", "family", "third"],
                additionalProperties: false
            )
        )
    }
}
