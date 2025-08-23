//
//  AppContainer.swift
//  NewMorph-iOS
//
//  Created by OneThing on 8/23/25.
//

import Foundation

/// 앱 전역 의존성을 한 곳에서 생성/보관하는 간단 컨테이너
@MainActor
@Observable
public final class AppContainer {
    public let useCase: NormalizeEnglishUseCase

    public init() {
        // 1) Config → Network → HTTP → OpenAIClient → UseCase
        let net = NetworkConfig(
            baseURL: URL(string: Config.openAIAPIBaseURL)!,
            apiKey: Config.openAIAPIKey
        )
        let http = URLSessionHTTPClient(config: net)
        let client = OpenAIResponsesClient(
            http: http,
            model: Config.openAIModel
        )

        self.useCase = NormalizeEnglishUseCase(client: client)
    }

    /// 미리보기/테스트용 목업을 쓰고 싶으면 별도 init 추가 가능
    public static func mock(
        friend: String =
            "I ended up with an egg sandwich, lol. I totally wanted some omurice and fruit juice, but I was out of time!",
        family: String =
            "I ate an egg sandwich because I didn't have enough time to enjoy the omurice and fruit juice I wanted.",
        third: String =
            "I grabbed an egg sandwich since I was out of time for the omurice and fruit juice I really wanted!",
        natural: String =
            "I had an egg sandwich because I didn't have time to eat the omurice and fruit juice I wanted."
    ) -> AppContainer {
        let mockClient = MockOpenAIClient(
            result: EnglishVariants(
                natural: natural,
                friend: friend,
                family: family,
                third: third
            )
        )
        return AppContainer(
            mockUseCase: NormalizeEnglishUseCase(client: mockClient)
        )
    }

    // 내부 전용 편의 이니셜라이저
    private init(mockUseCase: NormalizeEnglishUseCase) {
        self.useCase = mockUseCase
    }
}

// 간단한 목업 클라이언트 (선택)
final class MockOpenAIClient: OpenAIClient {
    private let result: EnglishVariants
    init(result: EnglishVariants) { self.result = result }
    func generateEnglishVariants(mixedText: String) async throws
        -> EnglishVariants
    { result }
}
