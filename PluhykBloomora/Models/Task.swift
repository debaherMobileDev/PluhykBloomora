//
//  Task.swift
//  PluhykBloomora
//
//  Created on 2026-01-24.
//

import Foundation

struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var priority: Priority
    var category: Category
    var isCompleted: Bool
    var createdDate: Date
    var dueDate: Date?
    var isHabit: Bool
    var habitStreak: Int
    
    enum Priority: String, Codable, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        
        var sortOrder: Int {
            switch self {
            case .high: return 0
            case .medium: return 1
            case .low: return 2
            }
        }
    }
    
    enum Category: String, Codable, CaseIterable {
        case personal = "Personal"
        case professional = "Professional"
        case health = "Health"
        case creative = "Creative"
        case other = "Other"
    }
    
    init(title: String, description: String, priority: Priority = .medium, category: Category = .personal, isCompleted: Bool = false, dueDate: Date? = nil, isHabit: Bool = false) {
        self.title = title
        self.description = description
        self.priority = priority
        self.category = category
        self.isCompleted = isCompleted
        self.createdDate = Date()
        self.dueDate = dueDate
        self.isHabit = isHabit
        self.habitStreak = 0
    }
}
