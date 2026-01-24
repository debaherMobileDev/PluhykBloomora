//
//  OnboardingView.swift
//  PluhykBloomora
//
//  Created on 2026-01-24.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage(DataPersistenceService.Keys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @AppStorage(DataPersistenceService.Keys.userName) private var userName = ""
    
    @State private var currentStep = 0
    @State private var nameInput = ""
    @State private var selectedActivities: Set<MindfulnessEntry.ActivityType> = []
    @State private var dailyGoalMinutes = 10
    
    private let steps = [
        OnboardingStep(
            title: "Welcome to Pluhyk Bloomora",
            description: "Your personal companion for growth, mindfulness, and creativity. Let's begin your journey to a better you.",
            imageName: "star.fill",
            color: "#2490ad"
        ),
        OnboardingStep(
            title: "Daily Positivity",
            description: "Start each day with inspiring quotes, practical tips, and motivational stories to fuel your success.",
            imageName: "sun.max.fill",
            color: "#3c166d"
        ),
        OnboardingStep(
            title: "Task Organization",
            description: "Manage your tasks with priority-based sorting, categorization, and habit tracking to stay productive.",
            imageName: "checkmark.circle.fill",
            color: "#1a2962"
        ),
        OnboardingStep(
            title: "Mindfulness Tracker",
            description: "Set daily mindfulness goals, track your meditation and yoga practice, and build a consistent routine.",
            imageName: "heart.fill",
            color: "#2490ad"
        ),
        OnboardingStep(
            title: "Creative Journal",
            description: "Express your thoughts, capture ideas, and reflect on your journey with guided prompts and insights.",
            imageName: "book.fill",
            color: "#3c166d"
        )
    ]
    
    var body: some View {
        ZStack {
            Color(hex: steps[currentStep].color)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Progress Indicator
                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentStep ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Icon
                Image(systemName: steps[currentStep].imageName)
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                
                // Title
                Text(steps[currentStep].title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Description
                Text(steps[currentStep].description)
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                
                // Personalization Section
                if currentStep == steps.count - 1 {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("What should we call you?")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            TextField("Your name", text: $nameInput)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: 300)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Daily mindfulness goal (minutes)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            HStack {
                                Button(action: {
                                    if dailyGoalMinutes > 5 {
                                        dailyGoalMinutes -= 5
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(Color(hex: "#fbaa1a"))
                                }
                                
                                Text("\(dailyGoalMinutes)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 60)
                                
                                Button(action: {
                                    if dailyGoalMinutes < 120 {
                                        dailyGoalMinutes += 5
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(Color(hex: "#fbaa1a"))
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Preferred mindfulness activities")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(MindfulnessEntry.ActivityType.allCases, id: \.self) { activity in
                                        Button(action: {
                                            if selectedActivities.contains(activity) {
                                                selectedActivities.remove(activity)
                                            } else {
                                                selectedActivities.insert(activity)
                                            }
                                        }) {
                                            VStack {
                                                Text(activity.icon)
                                                    .font(.system(size: 30))
                                                Text(activity.rawValue)
                                                    .font(.system(size: 12))
                                            }
                                            .padding(12)
                                            .background(
                                                selectedActivities.contains(activity) ?
                                                Color(hex: "#fbaa1a") : Color.white.opacity(0.2)
                                            )
                                            .foregroundColor(.white)
                                            .cornerRadius(12)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
                
                Spacer()
                
                // Buttons
                HStack(spacing: 15) {
                    if currentStep > 0 {
                        Button(action: {
                            withAnimation {
                                currentStep -= 1
                            }
                        }) {
                            Text("Back")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(15)
                        }
                    }
                    
                    Button(action: {
                        if currentStep < steps.count - 1 {
                            withAnimation {
                                currentStep += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    }) {
                        Text(currentStep < steps.count - 1 ? "Next" : "Get Started")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "#1a2962"))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#fbaa1a"))
                            .cornerRadius(15)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func completeOnboarding() {
        // Save user preferences
        if !nameInput.isEmpty {
            userName = nameInput
        }
        
        // Save mindfulness goal
        let goal = MindfulnessGoal(
            dailyGoalMinutes: dailyGoalMinutes,
            preferredActivities: Array(selectedActivities)
        )
        DataPersistenceService.shared.saveMindfulnessGoal(goal)
        
        // Mark onboarding as complete
        hasCompletedOnboarding = true
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
