//
//  OpenAIClient.swift
//  NewMorph-iOS
//
//  Created by OneThing on 8/23/25.
//

import Foundation

public protocol OpenAIClient {
    func generateEnglishVariants(mixedText: String) async throws
        -> EnglishVariants
}
