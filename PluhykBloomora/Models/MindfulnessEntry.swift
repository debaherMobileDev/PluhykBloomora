//
//  MindfulnessEntry.swift
//  PluhykBloomora
//
//  Created on 2026-01-24.
//

import Foundation

struct MindfulnessEntry: Identifiable, Codable {
    var id = UUID()
    var type: ActivityType
    var duration: Int // in minutes
    var date: Date
    var notes: String
    var completed: Bool
    
    enum ActivityType: String, Codable, CaseIterable {
        case meditation = "Meditation"
        case yoga = "Yoga"
        case breathing = "Breathing Exercise"
        case reflection = "Personal Reflection"
        case gratitude = "Gratitude Practice"
        case visualization = "Visualization"
        
        var icon: String {
            switch self {
            case .meditation: return "🧘"
            case .yoga: return "🧘‍♀️"
            case .breathing: return "💨"
            case .reflection: return "💭"
            case .gratitude: return "🙏"
            case .visualization: return "✨"
            }
        }
    }
    
    init(type: ActivityType, duration: Int, notes: String = "", completed: Bool = false) {
        self.type = type
        self.duration = duration
        self.date = Date()
        self.notes = notes
        self.completed = completed
    }
}

struct MindfulnessGoal: Codable {
    var dailyGoalMinutes: Int
    var preferredActivities: [MindfulnessEntry.ActivityType]
    var reminderTime: Date?
    
    init(dailyGoalMinutes: Int = 10, preferredActivities: [MindfulnessEntry.ActivityType] = [.meditation]) {
        self.dailyGoalMinutes = dailyGoalMinutes
        self.preferredActivities = preferredActivities
        self.reminderTime = nil
    }
}
