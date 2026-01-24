//
//  DataPersistenceService.swift
//  PluhykBloomora
//
//  Created on 2026-01-24.
//

import Foundation

class DataPersistenceService {
    static let shared = DataPersistenceService()
    
    private init() {}
    
    // MARK: - Generic Save/Load
    
    func save<T: Codable>(_ data: T, key: String) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func load<T: Codable>(key: String, as type: T.Type) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }
        return decoded
    }
    
    func delete(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    // MARK: - Specific Keys
    
    struct Keys {
        static let tasks = "pluhyk.tasks"
        static let journalEntries = "pluhyk.journalEntries"
        static let mindfulnessEntries = "pluhyk.mindfulnessEntries"
        static let mindfulnessGoal = "pluhyk.mindfulnessGoal"
        static let hasCompletedOnboarding = "pluhyk.hasCompletedOnboarding"
        static let userName = "pluhyk.userName"
        static let userPreferences = "pluhyk.userPreferences"
    }
    
    // MARK: - Tasks
    
    func saveTasks(_ tasks: [Task]) {
        save(tasks, key: Keys.tasks)
    }
    
    func loadTasks() -> [Task] {
        return load(key: Keys.tasks, as: [Task].self) ?? []
    }
    
    // MARK: - Journal Entries
    
    func saveJournalEntries(_ entries: [JournalEntry]) {
        save(entries, key: Keys.journalEntries)
    }
    
    func loadJournalEntries() -> [JournalEntry] {
        return load(key: Keys.journalEntries, as: [JournalEntry].self) ?? []
    }
    
    // MARK: - Mindfulness Entries
    
    func saveMindfulnessEntries(_ entries: [MindfulnessEntry]) {
        save(entries, key: Keys.mindfulnessEntries)
    }
    
    func loadMindfulnessEntries() -> [MindfulnessEntry] {
        return load(key: Keys.mindfulnessEntries, as: [MindfulnessEntry].self) ?? []
    }
    
    func saveMindfulnessGoal(_ goal: MindfulnessGoal) {
        save(goal, key: Keys.mindfulnessGoal)
    }
    
    func loadMindfulnessGoal() -> MindfulnessGoal {
        return load(key: Keys.mindfulnessGoal, as: MindfulnessGoal.self) ?? MindfulnessGoal()
    }
    
    // MARK: - Clear All Data
    
    func clearAllData() {
        delete(key: Keys.tasks)
        delete(key: Keys.journalEntries)
        delete(key: Keys.mindfulnessEntries)
        delete(key: Keys.mindfulnessGoal)
        delete(key: Keys.userName)
        delete(key: Keys.userPreferences)
    }
}
