//
//  MotivationService.swift
//  PluhykBloomora
//
//  Created on 2026-01-24.
//

import Foundation

class MotivationService {
    static let shared = MotivationService()
    
    private init() {}
    
    // MARK: - Daily Quotes
    
    private let quotes = [
        "The journey of a thousand miles begins with one step. - Lao Tzu",
        "Believe you can and you're halfway there. - Theodore Roosevelt",
        "The only way to do great work is to love what you do. - Steve Jobs",
        "Success is not final, failure is not fatal: it is the courage to continue that counts. - Winston Churchill",
        "Your limitation—it's only your imagination.",
        "Push yourself, because no one else is going to do it for you.",
        "Great things never come from comfort zones.",
        "Dream it. Wish it. Do it.",
        "Success doesn't just find you. You have to go out and get it.",
        "The harder you work for something, the greater you'll feel when you achieve it.",
        "Dream bigger. Do bigger.",
        "Don't stop when you're tired. Stop when you're done.",
        "Wake up with determination. Go to bed with satisfaction.",
        "Do something today that your future self will thank you for.",
        "Little things make big days.",
        "It's going to be hard, but hard does not mean impossible.",
        "Don't wait for opportunity. Create it.",
        "Sometimes we're tested not to show our weaknesses, but to discover our strengths.",
        "The key to success is to focus on goals, not obstacles.",
        "Dream it. Believe it. Build it.",
        "You are capable of amazing things.",
        "Be stronger than your excuses.",
        "The best time to plant a tree was 20 years ago. The second best time is now.",
        "Your only limit is your mind.",
        "Everything you've ever wanted is on the other side of fear. - George Addair"
    ]
    
    func getDailyQuote() -> String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let index = dayOfYear % quotes.count
        return quotes[index]
    }
    
    func getRandomQuote() -> String {
        return quotes.randomElement() ?? quotes[0]
    }
    
    // MARK: - Daily Tips
    
    private let tips = [
        "Start your day with a glass of water to hydrate your body.",
        "Take short breaks every hour to stretch and refresh your mind.",
        "Practice gratitude by writing down three things you're thankful for.",
        "Set clear priorities for your day to stay focused.",
        "Disconnect from screens an hour before bedtime for better sleep.",
        "Take a few deep breaths when feeling stressed.",
        "Celebrate small wins throughout your day.",
        "Keep a journal to track your thoughts and progress.",
        "Exercise for at least 20 minutes to boost your energy.",
        "Connect with a friend or loved one today.",
        "Read for 15 minutes to expand your knowledge.",
        "Practice mindfulness by being present in the moment.",
        "Organize your workspace for better productivity.",
        "Listen to uplifting music to improve your mood.",
        "Step outside for fresh air and natural light.",
        "Set boundaries to protect your time and energy.",
        "Learn something new to keep your mind sharp.",
        "Practice positive self-talk throughout the day.",
        "Prepare healthy snacks to fuel your body.",
        "Review your goals and adjust as needed."
    ]
    
    func getDailyTip() -> String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let index = dayOfYear % tips.count
        return tips[index]
    }
    
    // MARK: - Motivational Stories
    
    private let stories = [
        Story(
            title: "The Power of Consistency",
            content: "A young student struggled with mathematics. Instead of giving up, they committed to solving just three problems every day. After a year, they became one of the top students in their class. Small, consistent actions compound into remarkable results."
        ),
        Story(
            title: "From Failure to Success",
            content: "Thomas Edison failed thousands of times before inventing the light bulb. When asked about his failures, he said, 'I have not failed. I've just found 10,000 ways that won't work.' Every setback is a setup for a comeback."
        ),
        Story(
            title: "The Bamboo Tree",
            content: "The Chinese bamboo tree shows no visible growth for four years. Then, in the fifth year, it grows 90 feet in just six weeks. The tree was building a strong root system all along. Trust the process, even when you don't see immediate results."
        ),
        Story(
            title: "One Step at a Time",
            content: "A person decided to climb a mountain they had always dreamed of. The journey seemed impossible at first, but they focused on one step at a time. Months later, they stood at the summit, proving that any goal is achievable with persistence."
        ),
        Story(
            title: "The Starfish Story",
            content: "A young person threw stranded starfish back into the ocean one by one. When told they couldn't save them all, they replied, 'But I made a difference to that one.' Every positive action matters, no matter how small."
        ),
        Story(
            title: "Breaking Limits",
            content: "For years, experts believed running a mile in under four minutes was impossible. Then Roger Bannister did it in 1954. Within three years, 16 others broke the barrier too. Often, our biggest limits exist only in our minds."
        ),
        Story(
            title: "The Sculptor's Vision",
            content: "Michelangelo was asked how he created his masterpiece David. He replied, 'I saw David in the marble and carved until I set him free.' Your potential is already within you, waiting to be revealed."
        )
    ]
    
    struct Story: Identifiable {
        let id = UUID()
        let title: String
        let content: String
    }
    
    func getDailyStory() -> Story {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let index = dayOfYear % stories.count
        return stories[index]
    }
    
    // MARK: - Journal Prompts
    
    private let journalPrompts = [
        "What are three things that made you smile today?",
        "Describe a challenge you overcame recently and what you learned from it.",
        "What does your ideal day look like from start to finish?",
        "Write about a person who has positively influenced your life.",
        "What are you most grateful for right now?",
        "If you could give advice to your younger self, what would it be?",
        "What's a skill you'd like to develop and why?",
        "Describe a moment when you felt truly proud of yourself.",
        "What are your top three priorities in life right now?",
        "Write about a place that brings you peace and why.",
        "What limiting belief would you like to let go of?",
        "Describe your biggest dream and the first step toward it.",
        "What does success mean to you personally?",
        "Write about a recent experience that pushed you out of your comfort zone.",
        "What are five things you love about yourself?",
        "How do you want to be remembered?",
        "What brings you the most joy in life?",
        "Describe a lesson you learned the hard way.",
        "What would you do if you knew you couldn't fail?",
        "Write about your perfect evening routine."
    ]
    
    func getRandomJournalPrompt() -> String {
        return journalPrompts.randomElement() ?? journalPrompts[0]
    }
    
    func getDailyJournalPrompt() -> String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let index = dayOfYear % journalPrompts.count
        return journalPrompts[index]
    }
}
