//
//  AugustPrompts.swift
//  NewMorph-iOS
//
//  Created by mini on 8/24/25.
//

import Foundation

enum AugustPrompts {
    /// 1...30 (8월 1일 = 1) 의 프롬프트 반환
    static func prompt(for day: Int) -> String? {
        guard (1...30).contains(day) else { return nil }
        return all[day - 1]
    }

    /// 영어/한국어 한 줄씩 결합(↵ 포함)
    private static let all: [String] = [
        // Week 1: TMI
        "What was your most useless but happy moment today?\n오늘 쓸데없는데 괜히 행복했던 순간 뭐였어?",
        "What’s the last photo in your gallery? Tell me the story.\n너 사진첩 맨 위 사진 뭐야? 사연 좀 풀어봐.",
        "What’s the meme or reel you can’t stop watching these days?\n요즘 계속 돌려보는 밈/릴스 뭐야?",
        "What’s the weirdest snack combo you actually love?\n너만 좋아하는 이상한 간식 조합 뭐 있어?",
        "If your phone battery dies at 2%, who do you text first?\n폰 배터리 2% 남았을 때, 누구한테 먼저 톡 보내?",
        "What’s the laziest thing you did this week?\n이번 주에 제일 게으르게 했던 거 뭐야?",
        "Which app do you open the second you wake up?\n눈 뜨자마자 여는 앱 뭐야?",

        // Week 2: 관계
        "Which one’s worse: no reply all day vs left on read?\n하루종일 답장 없는 거 vs 읽씹, 뭐가 더 싫어?",
        "Would you rather fight with a friend or a partner?\n차라리 누구랑 싸우는 게 나아? 친구 vs 애인",
        "Do you usually say sorry first or just wait?\n싸우면 먼저 사과하는 편이야, 아님 시간 지나길 기다려?",
        "Would you share your Netflix account with your parents?\n부모님이랑 넷플릭스 계정 공유 가능?",
        "Which is scarier: meeting bae’s parents vs bae meeting yours?\n애인 부모님 만나는 거 vs 내 부모님이 애인 만나는 거, 뭐가 더 무서워?",
        "Who do you call first when something big happens?\n큰일 터지면 제일 먼저 전화하는 사람 누구야?",
        "Would you rather have no best friend or no partner?\n절친 없는 거 vs 애인 없는 거, 뭐가 더 힘들어?",

        // Week 3: 덕질/취향
        "If you swap life with your fave idol for a day, what’s the first thing you do?\n최애랑 하루 바꿔 살면 제일 먼저 뭐 하고 싶어?",
        "Which song are you addicted to right now?\n요즘 중독된 노래 뭐야?",
        "Which drama/movie do you rewatch over and over?\n몇 번을 다시 보는 드라마/영화 있어?",
        "What’s your ultimate comfort food?\n너한테 인생 위로음식 뭐야?",
        "Which YouTube channel do you binge-watch?\n무한정 보게 되는 유튜브 채널 뭐야?",
        "What was your first-ever fandom?\n네 인생 첫 덕질은 뭐였어?",
        "Which fictional character do you lowkey relate to?\n은근히 나랑 닮았다고 느끼는 캐릭터 있어?",

        // Week 4: 매운맛
        "On a date, who should pay first?\n데이트할 때 누가 먼저 계산해야 된다고 생각해?",
        "Which is worse: a dry texter or no texter?\n맨날 노잼 답장 vs 아예 연락 없음, 뭐가 더 최악?",
        "Would you rather have 3 days of no texts or daily boring texts?\n3일동안 연락 없음 vs 맨날 노잼 연락, 뭐가 더 싫어?",
        "Do you think love at first sight is real or cap?\n첫눈에 반한다는 거 믿어, 아니 뻥이라고 생각해?",
        "Would you rather ghost someone or get ghosted?\n네가 잠수 이별하는 거 vs 네가 당하는 거, 뭐가 나아?",
        "Which is more important: looks or vibe?\n얼굴 vs 분위기, 뭐가 더 중요해?",
        "What’s the most red flag thing you’ve seen in a date?\n데이트에서 본 제일 레드플래그 뭐였어?",

        // Week 5: 공감/현실
        "When do you feel the biggest “ugh” moment in daily life?\n하루 중 제일 “아… 싫다” 느낄 때 언제야?",
        "What does a real day-off look like for you?\n진짜 너다운 휴일은 어떤 날이야?"
    ]
}
