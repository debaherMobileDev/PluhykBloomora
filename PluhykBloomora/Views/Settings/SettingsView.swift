//
//  SettingsView.swift
//  PluhykBloomora
//
//  Created on 2026-01-24.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(DataPersistenceService.Keys.userName) private var userName = ""
    @AppStorage(DataPersistenceService.Keys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    
    @State private var showingDeleteConfirmation = false
    @State private var showingResetOnboarding = false
    @State private var tempUserName = ""
    
    var body: some View {
        NavigationView {
            Form {
                // Profile Section
                Section(header: Text("Profile")) {
                    HStack {
                        Text("Name")
                        Spacer()
                        if tempUserName.isEmpty {
                            Button(userName.isEmpty ? "Set Name" : userName) {
                                tempUserName = userName
                            }
                            .foregroundColor(Color(hex: "#2490ad"))
                        } else {
                            TextField("Your name", text: $tempUserName, onCommit: {
                                userName = tempUserName
                                tempUserName = ""
                            })
                            .multilineTextAlignment(.trailing)
                        }
                    }
                }
                
                // App Information
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("App")
                        Spacer()
                        Text("Pluhyk Bloomora")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Links
                Section(header: Text("Information")) {
                    NavigationLink(destination: WebLinkView(url: "https://pluhykbloomora.com/privacy-policy.html", title: "Privacy Policy")) {
                        HStack {
                            Image(systemName: "hand.raised")
                                .foregroundColor(Color(hex: "#2490ad"))
                            Text("Privacy Policy")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    NavigationLink(destination: WebLinkView(url: "https://pluhykbloomora.com/support.html", title: "Support")) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(Color(hex: "#2490ad"))
                            Text("Support")
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                // App Actions
                Section(header: Text("Actions")) {
                    Button(action: {
                        showingResetOnboarding = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(Color(hex: "#2490ad"))
                            Text("Reset Onboarding")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    NavigationLink(destination: DeleteAccountView()) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Delete All Data")
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                // Tips Section
                Section(header: Text("Tips")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Set daily goals to build consistency", systemImage: "target")
                        Label("Use journal prompts for inspiration", systemImage: "lightbulb")
                        Label("Track mindfulness to boost wellbeing", systemImage: "heart")
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            .alert("Reset Onboarding", isPresented: $showingResetOnboarding) {
                Button("Reset", role: .destructive) {
                    hasCompletedOnboarding = false
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will show you the onboarding screens again on next launch. Your data will not be affected.")
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
