//
//  MindfulnessViewModel.swift
//  PluhykBloomora
//
//  Created on 2026-01-24.
//

import Foundation
import SwiftUI
import Combine

class MindfulnessViewModel: ObservableObject {
    @Published var entries: [MindfulnessEntry] = []
    @Published var goal: MindfulnessGoal = MindfulnessGoal()
    
    private let persistence = DataPersistenceService.shared
    
    init() {
        loadData()
    }
    
    func loadData() {
        entries = persistence.loadMindfulnessEntries()
        goal = persistence.loadMindfulnessGoal()
    }
    
    func saveEntries() {
        persistence.saveMindfulnessEntries(entries)
    }
    
    func saveGoal() {
        persistence.saveMindfulnessGoal(goal)
    }
    
    func addEntry(_ entry: MindfulnessEntry) {
        entries.append(entry)
        saveEntries()
    }
    
    func updateEntry(_ entry: MindfulnessEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            saveEntries()
        }
    }
    
    func deleteEntry(_ entry: MindfulnessEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }
    
    func updateGoal(dailyMinutes: Int, activities: [MindfulnessEntry.ActivityType]) {
        goal.dailyGoalMinutes = dailyMinutes
        goal.preferredActivities = activities
        saveGoal()
    }
    
    // MARK: - Statistics
    
    func todayMinutes() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return entries
            .filter { calendar.isDate($0.date, inSameDayAs: today) && $0.completed }
            .reduce(0) { $0 + $1.duration }
    }
    
    func todayProgress() -> Double {
        let minutes = todayMinutes()
        guard goal.dailyGoalMinutes > 0 else { return 0 }
        return min(Double(minutes) / Double(goal.dailyGoalMinutes), 1.0)
    }
    
    func weeklyMinutes() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
        
        return entries
            .filter { $0.date >= weekAgo && $0.completed }
            .reduce(0) { $0 + $1.duration }
    }
    
    func totalMinutes() -> Int {
        return entries.filter { $0.completed }.reduce(0) { $0 + $1.duration }
    }
    
    func currentStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = Date()
        
        while true {
            let dayStart = calendar.startOfDay(for: currentDate)
            let hasEntry = entries.contains { entry in
                calendar.isDate(entry.date, inSameDayAs: dayStart) && entry.completed
            }
            
            if hasEntry {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
                currentDate = previousDay
            } else {
                break
            }
        }
        
        return streak
    }
    
    func entriesForLast7Days() -> [MindfulnessEntry] {
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
        
        return entries.filter { $0.date >= weekAgo }.sorted { $0.date > $1.date }
    }
    
    func mostFrequentActivity() -> MindfulnessEntry.ActivityType? {
        let activityCounts = Dictionary(grouping: entries.filter { $0.completed }) { $0.type }
            .mapValues { $0.count }
        
        return activityCounts.max { $0.value < $1.value }?.key
    }
}
