//
//  MindfulnessTrackerView.swift
//  PluhykBloomora
//
//  Created on 2026-01-24.
//

import SwiftUI

struct MindfulnessTrackerView: View {
    @StateObject private var viewModel = MindfulnessViewModel()
    @State private var showingAddActivity = false
    @State private var showingGoalSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 15) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Mindfulness")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Track your daily practice")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            Spacer()
                            
                            Button(action: {
                                showingGoalSettings = true
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Today's Progress
                        VStack(spacing: 12) {
                            HStack {
                                Text("Today's Goal")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(viewModel.todayMinutes()) / \(viewModel.goal.dailyGoalMinutes) min")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.white.opacity(0.3))
                                        .frame(height: 12)
                                        .cornerRadius(6)
                                    
                                    Rectangle()
                                        .fill(Color(hex: "#01ff00"))
                                        .frame(width: geometry.size.width * CGFloat(viewModel.todayProgress()), height: 12)
                                        .cornerRadius(6)
                                }
                            }
                            .frame(height: 12)
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "#3c166d"), Color(hex: "#1a2962")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Stats Cards
                            HStack(spacing: 12) {
                                StatCard(
                                    icon: "flame.fill",
                                    value: "\(viewModel.currentStreak())",
                                    label: "Day Streak",
                                    color: Color(hex: "#f0048d")
                                )
                                
                                StatCard(
                                    icon: "calendar",
                                    value: "\(viewModel.weeklyMinutes())",
                                    label: "Week Minutes",
                                    color: Color(hex: "#fbaa1a")
                                )
                                
                                StatCard(
                                    icon: "clock.fill",
                                    value: "\(viewModel.totalMinutes())",
                                    label: "Total Minutes",
                                    color: Color(hex: "#2490ad")
                                )
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            // Quick Add Activities
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Quick Add Activity")
                                    .font(.system(size: 18, weight: .bold))
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(MindfulnessEntry.ActivityType.allCases, id: \.self) { type in
                                            QuickActivityButton(type: type, viewModel: viewModel)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Recent Activities
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Recent Activities")
                                        .font(.system(size: 18, weight: .bold))
                                    Spacer()
                                    Button(action: {
                                        showingAddActivity = true
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "plus")
                                            Text("Add")
                                        }
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(hex: "#2490ad"))
                                    }
                                }
                                .padding(.horizontal)
                                
                                if viewModel.entries.isEmpty {
                                    VStack(spacing: 15) {
                                        Image(systemName: "heart.circle")
                                            .font(.system(size: 50))
                                            .foregroundColor(.gray)
                                        
                                        Text("No activities yet")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.gray)
                                        
                                        Text("Start your mindfulness journey today")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray.opacity(0.7))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                                } else {
                                    ForEach(viewModel.entriesForLast7Days()) { entry in
                                        MindfulnessEntryRow(entry: entry, viewModel: viewModel)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.bottom)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddActivity) {
                AddMindfulnessActivityView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingGoalSettings) {
                MindfulnessGoalSettingsView(viewModel: viewModel)
            }
        }
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct QuickActivityButton: View {
    let type: MindfulnessEntry.ActivityType
    let viewModel: MindfulnessViewModel
    @State private var showingDurationPicker = false
    @State private var selectedDuration = 10
    
    var body: some View {
        Button(action: {
            showingDurationPicker = true
        }) {
            VStack(spacing: 8) {
                Text(type.icon)
                    .font(.system(size: 30))
                
                Text(type.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: 100, height: 90)
            .foregroundColor(.white)
            .background(Color(hex: "#3c166d"))
            .cornerRadius(12)
        }
        .alert("Duration", isPresented: $showingDurationPicker) {
            Button("5 min") {
                addActivity(duration: 5)
            }
            Button("10 min") {
                addActivity(duration: 10)
            }
            Button("15 min") {
                addActivity(duration: 15)
            }
            Button("20 min") {
                addActivity(duration: 20)
            }
            Button("30 min") {
                addActivity(duration: 30)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("How long did you practice \(type.rawValue)?")
        }
    }
    
    private func addActivity(duration: Int) {
        let entry = MindfulnessEntry(type: type, duration: duration, completed: true)
        viewModel.addEntry(entry)
    }
}

struct MindfulnessEntryRow: View {
    let entry: MindfulnessEntry
    let viewModel: MindfulnessViewModel
    
    var body: some View {
        HStack(spacing: 15) {
            Text(entry.type.icon)
                .font(.system(size: 30))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.type.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                
                HStack {
                    Text("\(entry.duration) minutes")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                if !entry.notes.isEmpty {
                    Text(entry.notes)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            if entry.completed {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(hex: "#01ff00"))
                    .font(.system(size: 24))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct AddMindfulnessActivityView: View {
    @Environment(\.presentationMode) var presentationMode
    let viewModel: MindfulnessViewModel
    
    @State private var selectedType: MindfulnessEntry.ActivityType = .meditation
    @State private var duration = 10
    @State private var notes = ""
    @State private var completed = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Activity Type")) {
                    Picker("Type", selection: $selectedType) {
                        ForEach(MindfulnessEntry.ActivityType.allCases, id: \.self) { type in
                            HStack {
                                Text(type.icon)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                }
                
                Section(header: Text("Duration")) {
                    Stepper("\(duration) minutes", value: $duration, in: 1...120, step: 5)
                }
                
                Section(header: Text("Notes (Optional)")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                Section {
                    Toggle("Mark as Completed", isOn: $completed)
                }
            }
            .navigationTitle("Add Activity")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Add") {
                    let entry = MindfulnessEntry(
                        type: selectedType,
                        duration: duration,
                        notes: notes,
                        completed: completed
                    )
                    viewModel.addEntry(entry)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct MindfulnessGoalSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    let viewModel: MindfulnessViewModel
    
    @State private var dailyGoalMinutes: Int
    @State private var selectedActivities: Set<MindfulnessEntry.ActivityType>
    
    init(viewModel: MindfulnessViewModel) {
        self.viewModel = viewModel
        _dailyGoalMinutes = State(initialValue: viewModel.goal.dailyGoalMinutes)
        _selectedActivities = State(initialValue: Set(viewModel.goal.preferredActivities))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Daily Goal")) {
                    Stepper("\(dailyGoalMinutes) minutes", value: $dailyGoalMinutes, in: 5...120, step: 5)
                }
                
                Section(header: Text("Preferred Activities")) {
                    ForEach(MindfulnessEntry.ActivityType.allCases, id: \.self) { activity in
                        Button(action: {
                            if selectedActivities.contains(activity) {
                                selectedActivities.remove(activity)
                            } else {
                                selectedActivities.insert(activity)
                            }
                        }) {
                            HStack {
                                Text(activity.icon)
                                Text(activity.rawValue)
                                Spacer()
                                if selectedActivities.contains(activity) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color(hex: "#2490ad"))
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .navigationTitle("Goal Settings")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    viewModel.updateGoal(
                        dailyMinutes: dailyGoalMinutes,
                        activities: Array(selectedActivities)
                    )
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct MindfulnessTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        MindfulnessTrackerView()
    }
}
