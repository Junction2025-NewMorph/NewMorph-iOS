import SwiftUI
import Foundation

// MARK: - Tokenizer
struct Token: Equatable, Hashable {
    let text: String
    let type: TokenType
    
    enum TokenType {
        case word       // 단어 (영어, 한글)
        case punctuation // 문장부호
        case whitespace  // 공백, 탭, 줄바꿈
    }
}

class TextTokenizer {
    // 비교에서 제외할 특수문자들 (쉼표, 마침표, 느낌표, 물음표, 따옴표 등)
    private static let ignoredPunctuation: Set<String> = [
        ",", ".", "!", "?", ";", ":", "'", "\"", 
        "(", ")", "[", "]", "{", "}", 
        "-", "–", "—", "...", "…"
    ]
    
    static func tokenize(_ text: String) -> [Token] {
        var tokens: [Token] = []
        let nsString = text as NSString
        
        // 한글, 영어, 숫자를 포함한 단어
        let wordPattern = #"[\p{L}\p{N}]+"#
        // 공백 문자들
        let whitespacePattern = #"\s+"#
        // 문장부호 및 특수문자
        let punctuationPattern = #"[^\p{L}\p{N}\s]+"#
        
        let patterns = [
            (wordPattern, Token.TokenType.word),
            (whitespacePattern, Token.TokenType.whitespace),
            (punctuationPattern, Token.TokenType.punctuation)
        ]
        
        var currentIndex = 0
        
        while currentIndex < text.count {
            var matched = false
            
            for (pattern, tokenType) in patterns {
                let regex = try! NSRegularExpression(pattern: pattern, options: [])
                let range = NSRange(location: currentIndex, length: text.count - currentIndex)
                
                if let match = regex.firstMatch(in: text, options: .anchored, range: range) {
                    let matchedText = nsString.substring(with: match.range)
                    tokens.append(Token(text: matchedText, type: tokenType))
                    currentIndex = match.range.location + match.range.length
                    matched = true
                    break
                }
            }
            
            // 매칭되지 않은 문자가 있다면 개별 문자로 추가
            if !matched {
                let char = String(text[text.index(text.startIndex, offsetBy: currentIndex)])
                tokens.append(Token(text: char, type: .punctuation))
                currentIndex += 1
            }
        }
        
        return tokens
    }
    
    // Diff 비교용으로 특수문자를 필터링한 토큰 반환
    static func tokenizeForDiff(_ text: String) -> [Token] {
        let allTokens = tokenize(text)
        
        return allTokens.filter { token in
            // 특수문자 중에서 무시할 문자들은 제외
            if token.type == .punctuation {
                return !ignoredPunctuation.contains(token.text)
            }
            // 단어와 공백은 포함
            return true
        }
    }
    
    // 무시되는 특수문자인지 확인
    static func isPunctuationIgnored(_ text: String) -> Bool {
        return ignoredPunctuation.contains(text)
    }
}

// MARK: - Diff Operations
enum DiffOperation: Equatable {
    case equal(String)
    case insert(String)   // naturalText에만 있는 토큰 (초록 형광펜)
    case delete(String)   // originalText에만 있는 토큰 (볼드)
    case replace(from: String, to: String) // 치환 (from: 볼드, to: 초록 형광펜)
}

// MARK: - LCS 기반 Diff 알고리즘
class TextDiffer {
    static func diff(original: [Token], natural: [Token]) -> [DiffOperation] {
        let lcs = computeLCS(original, natural)
        return buildDiff(original: original, natural: natural, lcs: lcs)
    }
    
    private static func computeLCS(_ a: [Token], _ b: [Token]) -> [[Int]] {
        let m = a.count
        let n = b.count
        var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)
        
        for i in 1...m {
            for j in 1...n {
                if a[i-1] == b[j-1] {
                    dp[i][j] = dp[i-1][j-1] + 1
                } else {
                    dp[i][j] = max(dp[i-1][j], dp[i][j-1])
                }
            }
        }
        
        return dp
    }
    
    private static func buildDiff(original: [Token], natural: [Token], lcs: [[Int]]) -> [DiffOperation] {
        var operations: [DiffOperation] = []
        var i = original.count
        var j = natural.count
        
        while i > 0 && j > 0 {
            if original[i-1] == natural[j-1] {
                operations.insert(.equal(original[i-1].text), at: 0)
                i -= 1
                j -= 1
            } else if lcs[i-1][j] > lcs[i][j-1] {
                operations.insert(.delete(original[i-1].text), at: 0)
                i -= 1
            } else {
                operations.insert(.insert(natural[j-1].text), at: 0)
                j -= 1
            }
        }
        
        while i > 0 {
            operations.insert(.delete(original[i-1].text), at: 0)
            i -= 1
        }
        
        while j > 0 {
            operations.insert(.insert(natural[j-1].text), at: 0)
            j -= 1
        }
        
        return compactOperations(operations)
    }
    
    // delete + insert 연속을 replace로 압축
    private static func compactOperations(_ operations: [DiffOperation]) -> [DiffOperation] {
        var result: [DiffOperation] = []
        var i = 0
        
        while i < operations.count {
            if i + 1 < operations.count {
                switch (operations[i], operations[i + 1]) {
                case let (.delete(from), .insert(to)):
                    result.append(.replace(from: from, to: to))
                    i += 2
                    continue
                default:
                    break
                }
            }
            
            result.append(operations[i])
            i += 1
        }
        
        return result
    }
}

// MARK: - AttributedString Builder
class AttributedStringBuilder {
    
    static func buildOriginalAttributed(from operations: [DiffOperation]) -> AttributedString {
        var result = AttributedString()
        
        for operation in operations {
            switch operation {
            case .equal(let text):
                result.append(AttributedString(text))
                
            case .delete(let text):
                var attributedText = AttributedString(text)
                attributedText.font = .system(.body, design: .default, weight: .bold)
                result.append(attributedText)
                
            case .replace(let from, _):
                var attributedText = AttributedString(from)
                attributedText.font = .system(.body, design: .default, weight: .bold)
                result.append(attributedText)
                
            case .insert:
                // originalText에는 insert된 부분이 없으므로 생략
                break
            }
        }
        
        return result
    }
    
    static func buildNaturalAttributed(from operations: [DiffOperation]) -> AttributedString {
        var result = AttributedString()
        
        for operation in operations {
            switch operation {
            case .equal(let text):
                result.append(AttributedString(text))
                
            case .insert(let text):
                var attributedText = AttributedString(text)
                // iOS 15+ 호환을 위한 NSAttributedString 방식 사용
                if #available(iOS 15.0, *) {
                    // UIColor를 사용해서 backgroundColor 설정
                    attributedText.uiKit.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.4)
                    attributedText.uiKit.foregroundColor = UIColor.black
                }
                result.append(attributedText)
                
            case .replace(_, let to):
                var attributedText = AttributedString(to)
                // iOS 15+ 호환을 위한 NSAttributedString 방식 사용
                if #available(iOS 15.0, *) {
                    attributedText.uiKit.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.4)
                    attributedText.uiKit.foregroundColor = UIColor.black
                }
                result.append(attributedText)
                
            case .delete:
                // naturalText에는 delete된 부분이 없으므로 생략
                break
            }
        }
        
        return result
    }
    
    // 디버깅용 - 차이점을 콘솔에 출력 (특수문자 필터링 적용)
    static func printDifferences(original: String, natural: String) {
        let originalTokens = TextTokenizer.tokenizeForDiff(original)
        let naturalTokens = TextTokenizer.tokenizeForDiff(natural)
        let operations = TextDiffer.diff(original: originalTokens, natural: naturalTokens)
        
        print("=== Text Comparison (특수문자 필터링 적용) ===")
        print("Original: \"\(original)\"")
        print("Natural:  \"\(natural)\"")
        print("\nFiltered Original Tokens: \(originalTokens.map { "\"\($0.text)\"" }.joined(separator: ", "))")
        print("Filtered Natural Tokens: \(naturalTokens.map { "\"\($0.text)\"" }.joined(separator: ", "))")
        print("\nDifferences:")
        
        for (index, operation) in operations.enumerated() {
            switch operation {
            case .equal(let text):
                print("\(index): ✓ EQUAL - \"\(text)\"")
            case .delete(let text):
                print("\(index): 🟥 DELETE - \"\(text)\" (will be BOLD)")
            case .insert(let text):
                print("\(index): 🟢 INSERT - \"\(text)\" (will be HIGHLIGHTED)")
            case .replace(let from, let to):
                print("\(index): 🔄 REPLACE - \"\(from)\" -> \"\(to)\" (BOLD -> HIGHLIGHTED)")
            }
        }
        print("=== 필터링된 특수문자 목록 ===")
        let allOriginalTokens = TextTokenizer.tokenize(original)
        let filteredOut = allOriginalTokens.filter { TextTokenizer.isPunctuationIgnored($0.text) }
        if !filteredOut.isEmpty {
            print("제외된 특수문자: \(filteredOut.map { "\"\($0.text)\"" }.joined(separator: ", "))")
        } else {
            print("제외된 특수문자: 없음")
        }
        print("=====================\n")
    }
}