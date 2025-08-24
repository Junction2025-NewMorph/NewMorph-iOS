import SwiftUI
import Foundation

/// TextDiffer의 동작을 테스트하고 검증하는 유틸리티
struct TextDifferTest {
    
    /// 간단한 테스트 케이스들
    static func runTests() {
        print("🧪 TextDiffer 테스트 시작 (특수문자 필터링 적용)\n")
        
        // 테스트 1: 간단한 단어 차이
        print("📝 테스트 1: 단어 차이")
        testCase(
            original: "I like apple",
            natural: "I love apples"
        )
        
        // 테스트 2: 특수문자가 있는 경우 (필터링 테스트)
        print("📝 테스트 2: 특수문자 필터링")
        testCase(
            original: "Hello, world! How are you?",
            natural: "Hello world How are you"
        )
        
        // 테스트 3: 한글 포함
        print("📝 테스트 3: 한글 포함")
        testCase(
            original: "안녕하세요, 저는 학생이에요.",
            natural: "안녕하세요 저는 대학생입니다"
        )
        
        // 테스트 4: 영어+한글 혼합 + 특수문자
        print("📝 테스트 4: 영어+한글 혼합 + 특수문자")
        testCase(
            original: "I like 김치, very much!",
            natural: "I love kimchi so much"
        )
        
        // 테스트 5: 괄호와 따옴표 포함
        print("📝 테스트 5: 괄호와 따옴표")
        testCase(
            original: "He said \"Hello\" (with smile)",
            natural: "He said Hello with smile"
        )
        
        print("✅ 모든 테스트 완료\n")
    }
    
    private static func testCase(original: String, natural: String) {
        print("원문: '\(original)'")
        print("자연스러운 문장: '\(natural)'")
        
        // 전체 토크나이저 테스트
        let allOriginalTokens = TextTokenizer.tokenize(original)
        let allNaturalTokens = TextTokenizer.tokenize(natural)
        
        print("전체 원문 토큰: \(allOriginalTokens.map { "\"\($0.text)\"" }.joined(separator: ", "))")
        print("전체 자연 토큰: \(allNaturalTokens.map { "\"\($0.text)\"" }.joined(separator: ", "))")
        
        // 필터링된 토크나이저 테스트
        let originalTokens = TextTokenizer.tokenizeForDiff(original)
        let naturalTokens = TextTokenizer.tokenizeForDiff(natural)
        
        print("🔍 필터링된 원문 토큰: \(originalTokens.map { "\"\($0.text)\"" }.joined(separator: ", "))")
        print("🔍 필터링된 자연 토큰: \(naturalTokens.map { "\"\($0.text)\"" }.joined(separator: ", "))")
        
        // Diff 계산
        let operations = TextDiffer.diff(original: originalTokens, natural: naturalTokens)
        
        print("Diff 결과:")
        for (index, op) in operations.enumerated() {
            switch op {
            case .equal(let text):
                print("  \(index): ✓ 동일 - '\(text)'")
            case .delete(let text):
                print("  \(index): 🟥 삭제 - '\(text)' (볼드)")
            case .insert(let text):
                print("  \(index): 🟢 추가 - '\(text)' (형광펜)")
            case .replace(let from, let to):
                print("  \(index): 🔄 변경 - '\(from)' → '\(to)'")
            }
        }
        
        // AttributedString 생성 테스트
        let originalAS = AttributedStringBuilder.buildOriginalAttributed(from: operations)
        let naturalAS = AttributedStringBuilder.buildNaturalAttributed(from: operations)
        
        print("생성된 AttributedString 길이:")
        print("  원문: \(originalAS.characters.count)자")
        print("  자연: \(naturalAS.characters.count)자")
        print("---\n")
    }
}

/// SwiftUI에서 TextDiffer를 테스트하는 뷰
struct TextDifferTestView: View {
    @State private var originalText = "I like apple very much"
    @State private var naturalText = "I love apples so much"
    @State private var operations: [DiffOperation] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Text Differ 테스트")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("원문:")
                    .font(.headline)
                TextField("원본 텍스트", text: $originalText)
                    .textFieldStyle(.roundedBorder)
                
                Text("자연스러운 문장:")
                    .font(.headline)
                TextField("자연스러운 텍스트", text: $naturalText)
                    .textFieldStyle(.roundedBorder)
                
                Button("비교하기") {
                    updateDiff()
                }
                .buttonStyle(.borderedProminent)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("결과:")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("원문 (틀린 부분 볼드):")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(getOriginalAttributed())
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    
                    Text("자연스러운 문장 (수정된 부분 형광펜):")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(getNaturalAttributed())
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            updateDiff()
        }
    }
    
    private func updateDiff() {
        let originalTokens = TextTokenizer.tokenizeForDiff(originalText)
        let naturalTokens = TextTokenizer.tokenizeForDiff(naturalText)
        operations = TextDiffer.diff(original: originalTokens, natural: naturalTokens)
        
        // 콘솔에 디버그 정보 출력 (특수문자 필터링 적용)
        AttributedStringBuilder.printDifferences(original: originalText, natural: naturalText)
    }
    
    private func getOriginalAttributed() -> AttributedString {
        return AttributedStringBuilder.buildOriginalAttributed(from: operations)
    }
    
    private func getNaturalAttributed() -> AttributedString {
        return AttributedStringBuilder.buildNaturalAttributed(from: operations)
    }
}

#Preview {
    TextDifferTestView()
}