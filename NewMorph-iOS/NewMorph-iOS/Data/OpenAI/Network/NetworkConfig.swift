//
//  NetworkConfig.swift
//  NewMorph-iOS
//
//  Created by OneThing on 8/23/25.
//

import Foundation

public struct NetworkConfig {
    public let baseURL: URL
    public let apiKey: String
    public let timeout: TimeInterval
    public init(baseURL: URL, apiKey: String, timeout: TimeInterval = 30) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.timeout = timeout
    }
}
