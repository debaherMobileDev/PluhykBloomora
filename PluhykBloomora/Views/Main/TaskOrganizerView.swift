//
//  TaskOrganizerView.swift
//  PluhykBloomora
//
//  Created on 2026-01-24.
//

import SwiftUI

struct TaskOrganizerView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var showingAddTask = false
    @State private var selectedFilter: TaskFilter = .all
    @State private var selectedCategory: Task.Category? = nil
    
    enum TaskFilter: String, CaseIterable {
        case all = "All"
        case incomplete = "Active"
        case completed = "Completed"
        case habits = "Habits"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with gradient
                    VStack(spacing: 15) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Task Organizer")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("\(filteredTasks.count) tasks")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            Spacer()
                            
                            Button(action: {
                                showingAddTask = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(Color(hex: "#fbaa1a"))
                            }
                        }
                        
                        // Filter Buttons
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(TaskFilter.allCases, id: \.self) { filter in
                                    Button(action: {
                                        selectedFilter = filter
                                    }) {
                                        Text(filter.rawValue)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(selectedFilter == filter ? Color(hex: "#1a2962") : .white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                selectedFilter == filter ?
                                                Color(hex: "#fbaa1a") : Color.white.opacity(0.2)
                                            )
                                            .cornerRadius(20)
                                    }
                                }
                            }
                        }
                        
                        // Category Filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                Button(action: {
                                    selectedCategory = nil
                                }) {
                                    Text("All Categories")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(selectedCategory == nil ? Color(hex: "#1a2962") : .white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            selectedCategory == nil ?
                                            Color.white : Color.white.opacity(0.2)
                                        )
                                        .cornerRadius(15)
                                }
                                
                                ForEach(Task.Category.allCases, id: \.self) { category in
                                    Button(action: {
                                        selectedCategory = category
                                    }) {
                                        Text(category.rawValue)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(selectedCategory == category ? Color(hex: "#1a2962") : .white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                selectedCategory == category ?
                                                Color.white : Color.white.opacity(0.2)
                                            )
                                            .cornerRadius(15)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "#2490ad"), Color(hex: "#1a2962")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    
                    // Task List
                    if filteredTasks.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No tasks found")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            Text("Tap the + button to add a new task")
                                .font(.system(size: 14))
                                .foregroundColor(.gray.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(filteredTasks) { task in
                                TaskRowView(task: task, viewModel: viewModel)
                                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                    .listRowBackground(Color.clear)
                            }
                            .onDelete { indexSet in
                                indexSet.forEach { index in
                                    viewModel.deleteTask(filteredTasks[index])
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(viewModel: viewModel)
            }
        }
    }
    
    private var filteredTasks: [Task] {
        var tasks: [Task]
        
        switch selectedFilter {
        case .all:
            tasks = viewModel.sortedTasks()
        case .incomplete:
            tasks = viewModel.incompleteTasks()
        case .completed:
            tasks = viewModel.completedTasks()
        case .habits:
            tasks = viewModel.habitTasks()
        }
        
        if let category = selectedCategory {
            tasks = tasks.filter { $0.category == category }
        }
        
        return tasks
    }
}

struct TaskRowView: View {
    let task: Task
    let viewModel: TaskViewModel
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            HStack(spacing: 15) {
                // Completion Button
                Button(action: {
                    viewModel.toggleTaskCompletion(task)
                }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundColor(task.isCompleted ? Color(hex: "#01ff00") : priorityColor)
                }
                .buttonStyle(PlainButtonStyle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .strikethrough(task.isCompleted)
                    
                    if !task.description.isEmpty {
                        Text(task.description)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    HStack(spacing: 8) {
                        // Category Badge
                        Text(task.category.rawValue)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(categoryColor)
                            .cornerRadius(8)
                        
                        // Priority Badge
                        Text(task.priority.rawValue)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(priorityColor)
                            .cornerRadius(8)
                        
                        // Habit Indicator
                        if task.isHabit {
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                Text("\(task.habitStreak)")
                            }
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: "#f0048d"))
                            .cornerRadius(8)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            TaskDetailView(task: task, viewModel: viewModel)
        }
    }
    
    private var priorityColor: Color {
        switch task.priority {
        case .high:
            return Color(hex: "#f0048d")
        case .medium:
            return Color(hex: "#fbaa1a")
        case .low:
            return Color(hex: "#2490ad")
        }
    }
    
    private var categoryColor: Color {
        switch task.category {
        case .personal:
            return Color(hex: "#3c166d")
        case .professional:
            return Color(hex: "#1a2962")
        case .health:
            return Color(hex: "#01ff00").opacity(0.7)
        case .creative:
            return Color(hex: "#f0048d")
        case .other:
            return Color.gray
        }
    }
}

struct AddTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    let viewModel: TaskViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority: Task.Priority = .medium
    @State private var category: Task.Category = .personal
    @State private var isHabit = false
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                }
                
                Section(header: Text("Organization")) {
                    Picker("Priority", selection: $priority) {
                        ForEach(Task.Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    
                    Picker("Category", selection: $category) {
                        ForEach(Task.Category.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
                
                Section(header: Text("Options")) {
                    Toggle("Recurring Habit", isOn: $isHabit)
                    Toggle("Set Due Date", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Add") {
                    let newTask = Task(
                        title: title,
                        description: description,
                        priority: priority,
                        category: category,
                        dueDate: hasDueDate ? dueDate : nil,
                        isHabit: isHabit
                    )
                    viewModel.addTask(newTask)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(title.isEmpty)
            )
        }
    }
}

struct TaskDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let task: Task
    let viewModel: TaskViewModel
    
    @State private var editedTask: Task
    @State private var isEditing = false
    
    init(task: Task, viewModel: TaskViewModel) {
        self.task = task
        self.viewModel = viewModel
        _editedTask = State(initialValue: task)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    if isEditing {
                        TextField("Title", text: $editedTask.title)
                        TextField("Description", text: $editedTask.description)
                    } else {
                        Text(task.title)
                            .font(.headline)
                        Text(task.description)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Organization")) {
                    if isEditing {
                        Picker("Priority", selection: $editedTask.priority) {
                            ForEach(Task.Priority.allCases, id: \.self) { priority in
                                Text(priority.rawValue).tag(priority)
                            }
                        }
                        Picker("Category", selection: $editedTask.category) {
                            ForEach(Task.Category.allCases, id: \.self) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                    } else {
                        HStack {
                            Text("Priority")
                            Spacer()
                            Text(task.priority.rawValue)
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("Category")
                            Spacer()
                            Text(task.category.rawValue)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Status")) {
                    HStack {
                        Text("Completed")
                        Spacer()
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(task.isCompleted ? Color(hex: "#01ff00") : .gray)
                    }
                    
                    if task.isHabit {
                        HStack {
                            Text("Streak")
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(Color(hex: "#f0048d"))
                                Text("\(task.habitStreak) days")
                            }
                        }
                    }
                    
                    HStack {
                        Text("Created")
                        Spacer()
                        Text(task.createdDate.formatted(date: .abbreviated, time: .shortened))
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button(action: {
                        viewModel.toggleTaskCompletion(task)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Spacer()
                            Text(task.isCompleted ? "Mark as Incomplete" : "Mark as Complete")
                                .foregroundColor(Color(hex: "#2490ad"))
                            Spacer()
                        }
                    }
                    
                    Button(action: {
                        viewModel.deleteTask(task)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Spacer()
                            Text("Delete Task")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Task Details")
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(isEditing ? "Save" : "Edit") {
                    if isEditing {
                        viewModel.updateTask(editedTask)
                    }
                    isEditing.toggle()
                }
            )
        }
    }
}

struct TaskOrganizerView_Previews: PreviewProvider {
    static var previews: some View {
        TaskOrganizerView()
    }
}
