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
        static let openAIAPIBaseURL: String = "OPENAI_API_BASE_URL"
        static let openAIModel: String = "OPENAI_MODEL"
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
        print("🔑 Available keys in Info.plist: \(Config.infoDictionary.keys)")
        guard let key = Config.infoDictionary[Keys.openAIAPIKey] as? String else {
            fatalError(" OPENAI_API_KEY is not set in Info.plist for this configuration. Please add a string value for key '\(Keys.openAIAPIKey)'. ")
        }
        print("OPENAI_API_KEY loaded: \(key.prefix(10))...")
        return key
    }()

    static let openAIAPIBaseURL: String = {
        guard let url = Config.infoDictionary[Keys.openAIAPIBaseURL] as? String else {
            fatalError(" OPENAI_API_BASE_URL is not set in Info.plist for this configuration. Please add a string value for key '\(Keys.openAIAPIBaseURL)'. ⛔️🍞")
        }
        print("OPENAI_API_BASE_URL loaded: \(url)")
        return url
    }()

    static let openAIModel: String = {
        guard let model = Config.infoDictionary[Keys.openAIModel] as? String else {
            fatalError("🍞⛔️ OPENAI_MODEL is not set in Info.plist for this configuration. Please add a string value for key '\(Keys.openAIModel)'. ⛔️🍞")
        }
        return model
    }()
}
