//
//  Domain.swift
//  NewMorph-iOS
//
//  Created by eunsong on 8/24/25.
//

import Foundation

public final class MockQuestionsRepository: QuestionsRepository {

    private let questions: [String] = [
        // Week 1
        "What was your most useless but happy moment today?",
        "What’s the last photo in your gallery? Tell me the story.",
        "What’s the meme or reel you can’t stop watching these days?",
        "What’s the weirdest snack combo you actually love?",
        "If your phone battery dies at 2%, who do you text first?",
        "What’s the laziest thing you did this week?",
        "Which app do you open the second you wake up?",
        // Week 2
        "Which one’s worse: no reply all day vs left on read?",
        "Would you rather fight with a friend or a partner?",
        "Do you usually say sorry first or just wait?",
        "Would you share your Netflix account with your parents?",
        "Which is scarier: meeting bae’s parents vs bae meeting yours?",
        "Who do you call first when something big happens?",
        "Would you rather have no best friend or no partner?",
        // Week 3
        "If you swap life with your fave idol for a day, what’s the first thing you do?",
        "Which song are you addicted to right now?",
        "Which drama/movie do you rewatch over and over?",
        "What’s your ultimate comfort food?",
        "Which YouTube channel do you binge-watch?",
        "What was your first-ever fandom?",
        "Which fictional character do you lowkey relate to?",
        // Week 4
        "On a date, who should pay first?",
        "Which is worse: a dry texter or no texter?",
        "Would you rather have 3 days of no texts or daily boring texts?",
        "Do you think love at first sight is real or cap?",
        "Would you rather ghost someone or get ghosted?",
        "Which is more important: looks or vibe?",
        "What’s the most red flag thing you’ve seen in a date?",
        // Week 5
        "When do you feel the biggest “ugh” moment in daily life?",
        "What does a real day-off look like for you?",
    ]

    public init() {}

    // MARK: - QuestionsRepository
    public func fetchAll() -> [String] { questions }

    public func random() -> String {
        questions.randomElement() ?? "No questions available."
    }

    public func random(_ count: Int) -> [String] {
        guard count > 0 else { return [] }
        if count >= questions.count { return questions.shuffled() }
        return Array(questions.shuffled().prefix(count))
    }

    public func question(at index: Int) -> String? {
        guard questions.indices.contains(index) else { return nil }
        return questions[index]
    }
}
