//
//  CreativeJournalView.swift
//  PluhykBloomora
//
//  Created on 2026-01-24.
//

import SwiftUI

struct CreativeJournalView: View {
    @StateObject private var viewModel = JournalViewModel()
    @State private var showingAddEntry = false
    @State private var searchQuery = ""
    @State private var showingPrompt = false
    
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
                                Text("Creative Journal")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("\(viewModel.totalEntries()) entries")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            Spacer()
                            
                            Button(action: {
                                showingPrompt = true
                            }) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(Color(hex: "#fbaa1a"))
                            }
                        }
                        
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("Search entries...", text: $searchQuery)
                                .foregroundColor(.white)
                        }
                        .padding(12)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        
                        // Stats
                        HStack(spacing: 15) {
                            VStack {
                                Text("\(viewModel.entriesThisWeek())")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                Text("This Week")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.5))
                                .frame(height: 30)
                            
                            VStack {
                                Text("\(viewModel.entriesThisMonth())")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                Text("This Month")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.5))
                                .frame(height: 30)
                            
                            VStack {
                                Text("\(viewModel.totalEntries())")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Total")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "#f0048d"), Color(hex: "#3c166d")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    
                    // Entries List
                    if displayedEntries.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: searchQuery.isEmpty ? "book" : "magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text(searchQuery.isEmpty ? "No entries yet" : "No matching entries")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            if searchQuery.isEmpty {
                                Text("Start your journaling journey today")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray.opacity(0.7))
                                
                                Button(action: {
                                    showingAddEntry = true
                                }) {
                                    Text("Write Your First Entry")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 12)
                                        .background(Color(hex: "#f0048d"))
                                        .cornerRadius(25)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(displayedEntries) { entry in
                                JournalEntryRow(entry: entry, viewModel: viewModel)
                                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                    .listRowBackground(Color.clear)
                            }
                            .onDelete { indexSet in
                                indexSet.forEach { index in
                                    viewModel.deleteEntry(displayedEntries[index])
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddEntry) {
                AddJournalEntryView(viewModel: viewModel)
            }
            .alert("Writing Prompt", isPresented: $showingPrompt) {
                Button("Write About This") {
                    showingAddEntry = true
                }
                Button("Another Prompt") {
                    showingPrompt = true
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(viewModel.getRandomPrompt())
            }
        }
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showingAddEntry = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color(hex: "#f0048d"))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding()
                }
            }
        )
    }
    
    private var displayedEntries: [JournalEntry] {
        if searchQuery.isEmpty {
            return viewModel.sortedEntries()
        } else {
            return viewModel.searchEntries(query: searchQuery)
        }
    }
}

struct JournalEntryRow: View {
    let entry: JournalEntry
    let viewModel: JournalViewModel
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(entry.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if let mood = entry.mood {
                        Text(mood.rawValue.split(separator: " ").first ?? "")
                            .font(.system(size: 20))
                    }
                }
                
                Text(entry.content)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                
                HStack {
                    Text(entry.createdDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if !entry.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(entry.tags.prefix(3), id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color(hex: "#3c166d"))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            JournalEntryDetailView(entry: entry, viewModel: viewModel)
        }
    }
}

struct AddJournalEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    let viewModel: JournalViewModel
    
    @State private var title = ""
    @State private var content = ""
    @State private var selectedMood: JournalEntry.Mood? = nil
    @State private var tagInput = ""
    @State private var tags: [String] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Entry Details")) {
                    TextField("Title", text: $title)
                    
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("Write your thoughts...")
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $content)
                            .frame(minHeight: 150)
                    }
                }
                
                Section(header: Text("Mood (Optional)")) {
                    Picker("Mood", selection: $selectedMood) {
                        Text("None").tag(nil as JournalEntry.Mood?)
                        ForEach(JournalEntry.Mood.allCases, id: \.self) { mood in
                            Text(mood.rawValue).tag(mood as JournalEntry.Mood?)
                        }
                    }
                }
                
                Section(header: Text("Tags (Optional)")) {
                    HStack {
                        TextField("Add tag", text: $tagInput)
                        Button("Add") {
                            if !tagInput.isEmpty {
                                tags.append(tagInput)
                                tagInput = ""
                            }
                        }
                        .disabled(tagInput.isEmpty)
                    }
                    
                    if !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tags, id: \.self) { tag in
                                    HStack {
                                        Text("#\(tag)")
                                        Button(action: {
                                            tags.removeAll { $0 == tag }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color(hex: "#3c166d").opacity(0.2))
                                    .cornerRadius(15)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Entry")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    let entry = JournalEntry(
                        title: title.isEmpty ? "Untitled" : title,
                        content: content,
                        mood: selectedMood,
                        tags: tags
                    )
                    viewModel.addEntry(entry)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(content.isEmpty)
            )
        }
    }
}

struct JournalEntryDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let entry: JournalEntry
    let viewModel: JournalViewModel
    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedContent: String
    
    init(entry: JournalEntry, viewModel: JournalViewModel) {
        self.entry = entry
        self.viewModel = viewModel
        _editedTitle = State(initialValue: entry.title)
        _editedContent = State(initialValue: entry.content)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        if isEditing {
                            TextField("Title", text: $editedTitle)
                                .font(.system(size: 28, weight: .bold))
                        } else {
                            Text(entry.title)
                                .font(.system(size: 28, weight: .bold))
                        }
                        
                        HStack {
                            Text(entry.createdDate.formatted(date: .complete, time: .shortened))
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            
                            if let mood = entry.mood {
                                Spacer()
                                Text(mood.rawValue)
                                    .font(.system(size: 16))
                            }
                        }
                    }
                    .padding()
                    .background(Color(hex: "#f7f7f7"))
                    .cornerRadius(12)
                    
                    // Content
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Entry")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        if isEditing {
                            TextEditor(text: $editedContent)
                                .frame(minHeight: 200)
                                .padding(8)
                                .background(Color(hex: "#f7f7f7"))
                                .cornerRadius(8)
                        } else {
                            Text(entry.content)
                                .font(.system(size: 16))
                                .lineSpacing(6)
                        }
                    }
                    .padding()
                    
                    // Tags
                    if !entry.tags.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Tags")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.secondary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(entry.tags, id: \.self) { tag in
                                        Text("#\(tag)")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color(hex: "#3c166d"))
                                            .cornerRadius(15)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // Delete Button
                    Button(action: {
                        viewModel.deleteEntry(entry)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Spacer()
                            Text("Delete Entry")
                                .foregroundColor(.red)
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .navigationTitle("Journal Entry")
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(isEditing ? "Save" : "Edit") {
                    if isEditing {
                        var updatedEntry = entry
                        updatedEntry.title = editedTitle
                        updatedEntry.content = editedContent
                        viewModel.updateEntry(updatedEntry)
                    }
                    isEditing.toggle()
                }
            )
        }
    }
}


struct CreativeJournalView_Previews: PreviewProvider {
    static var previews: some View {
        CreativeJournalView()
    }
}
