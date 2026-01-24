//
//  JournalViewModel.swift
//  PluhykBloomora
//
//  Created on 2026-01-24.
//

import Foundation
import SwiftUI
import Combine

class JournalViewModel: ObservableObject {
    @Published var entries: [JournalEntry] = []
    
    private let persistence = DataPersistenceService.shared
    private let motivationService = MotivationService.shared
    
    init() {
        loadEntries()
    }
    
    func loadEntries() {
        entries = persistence.loadJournalEntries()
    }
    
    func saveEntries() {
        persistence.saveJournalEntries(entries)
    }
    
    func addEntry(_ entry: JournalEntry) {
        entries.append(entry)
        saveEntries()
    }
    
    func updateEntry(_ entry: JournalEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            saveEntries()
        }
    }
    
    func deleteEntry(_ entry: JournalEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }
    
    func sortedEntries() -> [JournalEntry] {
        return entries.sorted { $0.createdDate > $1.createdDate }
    }
    
    func entriesForMonth(_ date: Date) -> [JournalEntry] {
        let calendar = Calendar.current
        return entries.filter { entry in
            calendar.isDate(entry.createdDate, equalTo: date, toGranularity: .month)
        }
    }
    
    func entriesWithMood(_ mood: JournalEntry.Mood) -> [JournalEntry] {
        return entries.filter { $0.mood == mood }
    }
    
    func searchEntries(query: String) -> [JournalEntry] {
        guard !query.isEmpty else { return sortedEntries() }
        
        let lowercasedQuery = query.lowercased()
        return entries.filter { entry in
            entry.title.lowercased().contains(lowercasedQuery) ||
            entry.content.lowercased().contains(lowercasedQuery) ||
            entry.tags.contains { $0.lowercased().contains(lowercasedQuery) }
        }.sorted { $0.createdDate > $1.createdDate }
    }
    
    func getRandomPrompt() -> String {
        return motivationService.getRandomJournalPrompt()
    }
    
    func totalEntries() -> Int {
        return entries.count
    }
    
    func entriesThisWeek() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
        
        return entries.filter { $0.createdDate >= weekAgo }.count
    }
    
    func entriesThisMonth() -> Int {
        let calendar = Calendar.current
        let now = Date()
        
        return entries.filter { entry in
            calendar.isDate(entry.createdDate, equalTo: now, toGranularity: .month)
        }.count
    }
}
