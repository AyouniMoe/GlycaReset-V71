//
//  Impact.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import Foundation
import SwiftUI

// MARK: - Impact Models

enum ActivityType: String, Codable, CaseIterable {
    case all = "all"
    case diet = "diet"
    case lifestyle = "lifestyle"
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .diet: return "Diet"
        case .lifestyle: return "Lifestyle"
        }
    }
}

enum ActivityCategory: String, Codable {
    case fasting = "fasting"
    case meal = "meal"
    case exercise = "exercise"
    case meditation = "meditation"
    case sleep = "sleep"
    case water = "water"
    case bloodSugarLog = "blood_sugar_log"
    case habit = "habit"
    
    var icon: String {
        switch self {
        case .fasting: return "clock.fill"
        case .meal: return "fork.knife"
        case .exercise: return "figure.walk"
        case .meditation: return "brain.head.profile"
        case .sleep: return "moon.stars.fill"
        case .water: return "drop.fill"
        case .bloodSugarLog: return "waveform.path.ecg"
        case .habit: return "target"
        }
    }
    
    var color: Color {
        switch self {
        case .fasting: return Color(red: 0.2, green: 0.6, blue: 1.0) // Blue
        case .meal: return Color(red: 0.2, green: 0.8, blue: 0.4) // Green
        case .exercise: return Color(red: 0.6, green: 0.4, blue: 0.9) // Purple
        case .meditation: return Color(red: 0.6, green: 0.4, blue: 0.9) // Purple
        case .sleep: return Color(red: 0.2, green: 0.6, blue: 1.0) // Blue
        case .water: return Color(red: 0.2, green: 0.6, blue: 1.0) // Blue
        case .bloodSugarLog: return Color(red: 0.2, green: 0.8, blue: 0.4) // Green
        case .habit: return Color(red: 1.0, green: 0.6, blue: 0.2) // Orange
        }
    }
    
    var activityType: ActivityType {
        switch self {
        case .fasting, .meal, .water, .bloodSugarLog:
            return .diet
        case .exercise, .meditation, .sleep, .habit:
            return .lifestyle
        }
    }
}

struct ActivityImpact: Codable, Identifiable {
    let id: UUID
    let category: ActivityCategory
    let title: String
    let description: String
    let date: Date
    let xpEarned: Int
    let impacts: [MetricImpact]
    
    init(id: UUID = UUID(), category: ActivityCategory, title: String, description: String, date: Date = Date(), xpEarned: Int, impacts: [MetricImpact] = []) {
        self.id = id
        self.category = category
        self.title = title
        self.description = description
        self.date = date
        self.xpEarned = xpEarned
        self.impacts = impacts
    }
}

struct MetricImpact: Codable {
    let metric: String // e.g., "Blood Glucose", "Weight", "Stress Reduction"
    let value: Double
    let unit: String // e.g., "mg/dL", "lbs", "%"
    let isPositive: Bool // true for reductions/improvements
    
    init(metric: String, value: Double, unit: String, isPositive: Bool = true) {
        self.metric = metric
        self.value = value
        self.unit = unit
        self.isPositive = isPositive
    }
}

struct WeeklyImpactSummary: Codable {
    let weekStartDate: Date
    let totalXP: Int
    let avgGlucoseReduction: Double
    let weightLoss: Double
    let activitiesLogged: Int
    let activeDays: Int
    let totalDays: Int
    
    var activeDaysRatio: Double {
        guard totalDays > 0 else { return 0 }
        return Double(activeDays) / Double(totalDays)
    }
    
    var progressMessage: String {
        if activeDaysRatio >= 0.85 && avgGlucoseReduction > 20 {
            return "AMAZING PROGRESS!"
        } else if activeDaysRatio >= 0.7 && avgGlucoseReduction > 10 {
            return "GREAT WORK!"
        } else if activeDaysRatio >= 0.5 {
            return "KEEP GOING!"
        } else {
            return "GET STARTED!"
        }
    }
}

