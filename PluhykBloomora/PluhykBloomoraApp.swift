//
//  PluhykBloomoraApp.swift
//  PluhykBloomora
//
//  Created on 2026-01-24.
//

import SwiftUI

@main
struct PluhykBloomoraApp: App {
    
    // Регистрируем AppDelegate для Firebase
    @UIApplicationDelegateAdaptor(FirebaseAppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            LaunchDecisionView()
        }
    }
}

struct MainView: View {
    @AppStorage(DataPersistenceService.Keys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    
    var body: some View {
        Group {
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
}
