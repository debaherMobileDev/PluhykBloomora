//
//  OnboardingStep.swift
//  PluhykBloomora
//
//  Created on 2026-01-24.
//

import Foundation

struct OnboardingStep: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let color: String
}
