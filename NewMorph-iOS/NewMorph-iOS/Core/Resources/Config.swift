//
//  Config.swift
//  NewMorph-iOS
//
//  Created by mini on 8/22/25.
//

import Foundation

enum Config {
    enum Keys {
        static let openAIAPIKey: String = "OPENAI_API_KEY"
    }
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("plist cannot found !!!")
        }
        return dict
    }()
}

extension Config {
    static let openAIAPIKey: String = {
        guard let key = Config.infoDictionary[Keys.openAIAPIKey] as? String else {
            fatalError("🍞⛔️OPENAI_API_KEY is not set in plist for this configuration⛔️🍞")
        }
        return key
    }()
}
