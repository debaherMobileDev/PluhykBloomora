//
//  DashboardView.swift
//  PluhykBloomora
//
//  Created on 2026-01-24.
//

import SwiftUI

struct DashboardView: View {
    @AppStorage(DataPersistenceService.Keys.userName) private var userName = ""
    @StateObject private var taskViewModel = TaskViewModel()
    @StateObject private var mindfulnessViewModel = MindfulnessViewModel()
    @StateObject private var journalViewModel = JournalViewModel()
    
    private let motivationService = MotivationService.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome back\(userName.isEmpty ? "" : ", \(userName)")!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(Date().formatted(date: .complete, time: .omitted))
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(hex: "#2490ad"))
                
                // Daily Positivity Section
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(Color(hex: "#fbaa1a"))
                        Text("Daily Positivity Boost")
                            .font(.system(size: 20, weight: .bold))
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Quote Card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "quote.opening")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "#fbaa1a"))
                            Text("Quote of the Day")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        
                        Text(motivationService.getDailyQuote())
                            .font(.system(size: 15))
                            .italic()
                            .foregroundColor(.primary.opacity(0.9))
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "#f7f7f7"))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Tip Card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "#f0048d"))
                            Text("Today's Tip")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        
                        Text(motivationService.getDailyTip())
                            .font(.system(size: 15))
                            .foregroundColor(.primary.opacity(0.9))
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "#f7f7f7"))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Story Card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "book.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "#3c166d"))
                            Text(motivationService.getDailyStory().title)
                                .font(.system(size: 16, weight: .semibold))
                        }
                        
                        Text(motivationService.getDailyStory().content)
                            .font(.system(size: 14))
                            .foregroundColor(.primary.opacity(0.8))
                            .lineLimit(4)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "#f7f7f7"))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.vertical)
                
                // Quick Stats
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(Color(hex: "#1a2962"))
                        Text("Your Progress")
                            .font(.system(size: 20, weight: .bold))
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HStack(spacing: 12) {
                        // Tasks Stat
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(Color(hex: "#fbaa1a"))
                            Text("\(taskViewModel.incompleteTasks().count)")
                                .font(.system(size: 24, weight: .bold))
                            Text("Active Tasks")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#f7f7f7"))
                        .cornerRadius(12)
                        
                        // Mindfulness Stat
                        VStack(spacing: 8) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 30))
                                .foregroundColor(Color(hex: "#f0048d"))
                            Text("\(mindfulnessViewModel.todayMinutes())")
                                .font(.system(size: 24, weight: .bold))
                            Text("Minutes Today")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#f7f7f7"))
                        .cornerRadius(12)
                        
                        // Journal Stat
                        VStack(spacing: 8) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 30))
                                .foregroundColor(Color(hex: "#3c166d"))
                            Text("\(journalViewModel.entriesThisWeek())")
                                .font(.system(size: 24, weight: .bold))
                            Text("Entries This Week")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#f7f7f7"))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
