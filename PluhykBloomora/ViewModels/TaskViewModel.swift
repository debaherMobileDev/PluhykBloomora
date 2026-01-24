//
//  TaskViewModel.swift
//  PluhykBloomora
//
//  Created on 2026-01-24.
//

import Foundation
import SwiftUI
import Combine

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    
    private let persistence = DataPersistenceService.shared
    
    init() {
        loadTasks()
    }
    
    func loadTasks() {
        tasks = persistence.loadTasks()
    }
    
    func saveTasks() {
        persistence.saveTasks(tasks)
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
        saveTasks()
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func toggleTaskCompletion(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            
            // If it's a habit and being marked complete, increment streak
            if tasks[index].isHabit && tasks[index].isCompleted {
                tasks[index].habitStreak += 1
            }
            
            saveTasks()
        }
    }
    
    func sortedTasks() -> [Task] {
        return tasks.sorted { task1, task2 in
            // First sort by completion status
            if task1.isCompleted != task2.isCompleted {
                return !task1.isCompleted
            }
            // Then by priority
            if task1.priority.sortOrder != task2.priority.sortOrder {
                return task1.priority.sortOrder < task2.priority.sortOrder
            }
            // Finally by date
            return task1.createdDate > task2.createdDate
        }
    }
    
    func tasksByCategory(_ category: Task.Category) -> [Task] {
        return tasks.filter { $0.category == category }
    }
    
    func incompleteTasks() -> [Task] {
        return tasks.filter { !$0.isCompleted }
    }
    
    func completedTasks() -> [Task] {
        return tasks.filter { $0.isCompleted }
    }
    
    func habitTasks() -> [Task] {
        return tasks.filter { $0.isHabit }
    }
    
    func completionRate() -> Double {
        guard !tasks.isEmpty else { return 0 }
        let completed = tasks.filter { $0.isCompleted }.count
        return Double(completed) / Double(tasks.count)
    }
}
