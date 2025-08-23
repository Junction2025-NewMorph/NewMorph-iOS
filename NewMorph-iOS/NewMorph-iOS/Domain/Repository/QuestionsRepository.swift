//
//  QuestionsRepository.swift
//  NewMorph-iOS
//
//  Created by eunsong on 8/24/25.
//

import Foundation

public protocol QuestionsRepository {
    /// 모든 질문
    func fetchAll() -> [String]
    /// 랜덤 1개
    func random() -> String
    /// 랜덤 N개 (중복 없이, 가능한 만큼)
    func random(_ count: Int) -> [String]
    /// 인덱스로 접근 (0-based)
    func question(at index: Int) -> String?
}
