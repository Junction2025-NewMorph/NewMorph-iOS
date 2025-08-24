//
//  TextDiffUtility.swift
//  NewMorph-iOS
//
//  Created by OneThing on 8/23/25.
//

import Foundation
import SwiftUI

/// 사용자 입력과 정답 텍스트를 비교하여 틀린 부분을 하이라이트하는 유틸리티
struct TextDiffUtility {
    
    /// 토큰화: 단어/숫자/축약형 보존, 대소문자·문장부호 처리
    private static func tokenize(_ string: String) -> [String] {
        // 단순 토크나이저: 알파벳/숫자/' 를 단어로, 나머지는 개별 토큰
        let pattern = "[A-Za-z0-9']+|[^\\sA-Za-z0-9']"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let nsString = string as NSString
        return regex.matches(in: string, range: NSRange(location: 0, length: nsString.length)).map {
            nsString.substring(with: $0.range)
        }
    }
    
    /// LCS(최장공통부분수열)로 사용자/정답 정렬
    private static func lcsMap(_ userTokens: [String], _ correctTokens: [String]) -> [(userIndex: Int?, correctIndex: Int?)] {
        let n = userTokens.count
        let m = correctTokens.count
        var dp = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)
        
        // DP 테이블 채우기
        for i in (0..<n).reversed() {
            for j in (0..<m).reversed() {
                if userTokens[i].lowercased() == correctTokens[j].lowercased() {
                    dp[i][j] = dp[i + 1][j + 1] + 1
                } else {
                    dp[i][j] = max(dp[i + 1][j], dp[i][j + 1])
                }
            }
        }
        
        // backtrack → 정렬된 페어 시퀀스
        var i = 0, j = 0
        var pairs: [(Int?, Int?)] = []
        
        while i < n && j < m {
            if userTokens[i].lowercased() == correctTokens[j].lowercased() {
                pairs.append((i, j))
                i += 1
                j += 1
            } else if dp[i + 1][j] >= dp[i][j + 1] {
                pairs.append((i, nil)) // 사용자에만 있음(삭제/치환)
                i += 1
            } else {
                pairs.append((nil, j)) // 정답에만 있음(추가/치환)
                j += 1
            }
        }
        
        // 남은 토큰들 처리
        while i < n {
            pairs.append((i, nil))
            i += 1
        }
        while j < m {
            pairs.append((nil, j))
            j += 1
        }
        
        return pairs
    }
    
    /// 사용자 문장에서 "틀린/빠진/치환" 토큰의 NSRange 목록 생성
    static func mismatchRanges(in userText: String, comparedTo correctText: String) -> [NSRange] {
        let userTokens = tokenize(userText)
        let correctTokens = tokenize(correctText)
        let pairs = lcsMap(userTokens, correctTokens)
        
        // 사용자 원문 내 토큰의 NSRange 인덱싱
        var mismatchRanges: [NSRange] = []
        let nsUserText = userText as NSString
        let pattern = "[A-Za-z0-9']+|[^\\sA-Za-z0-9']"
        let regex = try! NSRegularExpression(pattern: pattern)
        let tokenRanges = regex.matches(in: userText, range: NSRange(location: 0, length: nsUserText.length)).map { $0.range }
        
        // pairs를 순회하며 사용자 쪽 불일치 토큰을 수집
        for pair in pairs {
            switch (pair.userIndex, pair.correctIndex) {
            case let (.some(userIndex), .some(_)):
                // 동일 토큰 → 통과
                break
            case let (.some(userIndex), .none):
                // 사용자에만 존재(삭제 혹은 치환의 사용자측): 하이라이트 대상
                if userIndex < tokenRanges.count {
                    mismatchRanges.append(tokenRanges[userIndex])
                }
            case (.none, .some(_)):
                // 정답에만 존재(추가): 사용자에는 없음 → 시각화 원하면 "삽입 위치" 마커로 처리 가능
                break
            default:
                break
            }
        }
        
        return mismatchRanges
    }
    
    /// AttributedString 생성 (형광펜 배경 + 굵기)
    static func highlightedUserAttributedText(userText: String, correctText: String) -> AttributedString {
        var attributedString = AttributedString(userText)
        let rangesToHighlight = mismatchRanges(in: userText, comparedTo: correctText)
        
        for range in rangesToHighlight {
            if let stringRange = Range(range, in: userText) {
                var segment = AttributedString(String(userText[stringRange]))
                segment.backgroundColor = Color("nmGreen").opacity(0.55)   // nmGreen 형광펜
                segment.foregroundColor = .black
                segment.font = .system(.body, weight: .semibold)
                
                // 해당 범위의 텍스트를 하이라이트된 버전으로 교체
                let attributedRange = attributedString.range(of: String(userText[stringRange]))
                if let attributedRange = attributedRange {
                    attributedString.replaceSubrange(attributedRange, with: segment)
                }
            }
        }
        
        return attributedString
    }
}