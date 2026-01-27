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
        ),
        OnboardingStep(
            title: "Personalize Your Experience",
            description: "Tell us about yourself and set your daily mindfulness goals.",
            imageName: "person.fill",
            color: "#1a2962"
        ),
        OnboardingStep(
            title: "Choose Your Activities",
            description: "Select the mindfulness activities you'd like to practice.",
            imageName: "sparkles",
            color: "#3c166d"
        )
    ]
    
    var body: some View {
        ZStack {
            Color(hex: steps[currentStep].color)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // Progress Indicator
                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentStep ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                // Scrollable Content
                ScrollView {
                    VStack(spacing: 30) {
                        Spacer()
                            .frame(height: 20)
                        
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
                        
                        // Personalization Section - Step 6 (Name and Goal)
                        if currentStep == 5 {
                            VStack(spacing: 25) {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("What should we call you?")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    TextField("Your name", text: $nameInput)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(maxWidth: 350)
                                        .font(.system(size: 16))
                                }
                                .frame(maxWidth: .infinity)
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Daily mindfulness goal")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    HStack(spacing: 20) {
                                        Button(action: {
                                            if dailyGoalMinutes > 5 {
                                                dailyGoalMinutes -= 5
                                            }
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .font(.system(size: 40))
                                                .foregroundColor(Color(hex: "#fbaa1a"))
                                        }
                                        
                                        VStack(spacing: 4) {
                                            Text("\(dailyGoalMinutes)")
                                                .font(.system(size: 48, weight: .bold))
                                                .foregroundColor(.white)
                                            
                                            Text("minutes")
                                                .font(.system(size: 16))
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                        .frame(width: 120)
                                        
                                        Button(action: {
                                            if dailyGoalMinutes < 120 {
                                                dailyGoalMinutes += 5
                                            }
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: 40))
                                                .foregroundColor(Color(hex: "#fbaa1a"))
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal, 30)
                        }
                        
                        // Activity Selection - Step 7
                        if currentStep == 6 {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Select activities you'd like to practice:")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 30)
                                
                                VStack(spacing: 12) {
                                    ForEach(MindfulnessEntry.ActivityType.allCases, id: \.self) { activity in
                                        Button(action: {
                                            if selectedActivities.contains(activity) {
                                                selectedActivities.remove(activity)
                                            } else {
                                                selectedActivities.insert(activity)
                                            }
                                        }) {
                                            HStack(spacing: 15) {
                                                Text(activity.icon)
                                                    .font(.system(size: 28))
                                                
                                                Text(activity.rawValue)
                                                    .font(.system(size: 17, weight: .medium))
                                                    .foregroundColor(.white)
                                                
                                                Spacer()
                                                
                                                Image(systemName: selectedActivities.contains(activity) ? "checkmark.circle.fill" : "circle")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(selectedActivities.contains(activity) ? Color(hex: "#fbaa1a") : .white.opacity(0.5))
                                            }
                                            .padding()
                                            .background(
                                                selectedActivities.contains(activity) ?
                                                Color.white.opacity(0.25) : Color.white.opacity(0.1)
                                            )
                                            .cornerRadius(12)
                                        }
                                    }
                                }
                                .padding(.horizontal, 30)
                            }
                        }
                        
                        Spacer()
                            .frame(height: 40)
                    }
                }
                
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
