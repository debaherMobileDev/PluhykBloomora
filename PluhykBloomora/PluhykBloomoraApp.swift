//
//  PluhykBloomoraApp.swift
//  PluhykBloomora
//
//  Created on 2026-01-24.
//

import SwiftUI

@main
struct PluhykBloomoraApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

struct MainView: View {
    @AppStorage(DataPersistenceService.Keys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    
    var body: some View {
        if hasCompletedOnboarding {
            TabView {
                DashboardView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                
                TaskOrganizerView()
                    .tabItem {
                        Label("Tasks", systemImage: "checkmark.circle.fill")
                    }
                
                MindfulnessTrackerView()
                    .tabItem {
                        Label("Mindfulness", systemImage: "heart.fill")
                    }
                
                CreativeJournalView()
                    .tabItem {
                        Label("Journal", systemImage: "book.fill")
                    }
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
            }
            .accentColor(Color(hex: "#2490ad"))
        } else {
            OnboardingView()
        }
    }
}
