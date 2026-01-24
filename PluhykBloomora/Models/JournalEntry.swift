//
//  JournalEntry.swift
//  PluhykBloomora
//
//  Created on 2026-01-24.
//

import Foundation

struct JournalEntry: Identifiable, Codable {
    var id = UUID()
    var title: String
    var content: String
    var createdDate: Date
    var mood: Mood?
    var tags: [String]
    
    enum Mood: String, Codable, CaseIterable {
        case joyful = "😊 Joyful"
        case peaceful = "😌 Peaceful"
        case thoughtful = "🤔 Thoughtful"
        case energetic = "⚡ Energetic"
        case grateful = "🙏 Grateful"
        case creative = "🎨 Creative"
        case reflective = "💭 Reflective"
    }
    
    init(title: String, content: String, mood: Mood? = nil, tags: [String] = []) {
        self.title = title
        self.content = content
        self.createdDate = Date()
        self.mood = mood
        self.tags = tags
    }
}
