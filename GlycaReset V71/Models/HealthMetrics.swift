//
//  HealthMetrics.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import Foundation
import SwiftUI

// MARK: - Health Metric Data Models

struct HealthMetric: Codable, Identifiable {
    let id: UUID
    let type: MetricType
    let value: Double
    let date: Date
    
    init(id: UUID = UUID(), type: MetricType, value: Double, date: Date = Date()) {
        self.id = id
        self.type = type
        self.value = value
        self.date = date
    }
}

enum MetricType: String, Codable {
    case hba1c = "hba1c"
    case fastingBloodGlucose = "fasting_blood_glucose"
    case postprandialGlucose = "postprandial_glucose"
    case weight = "weight"
    case sleepQuality = "sleep_quality"
    case stressLevel = "stress_level"
    case lifestyleAdherence = "lifestyle_adherence"
    case dietAdherence = "diet_adherence"
    case steps = "steps"
}

struct MetricTarget: Codable {
    let type: MetricType
    let targetValue: Double
}

struct HbA1cTestReminder: Codable {
    let id: UUID
    var scheduledDate: Date
    var isCompleted: Bool
    
    init(id: UUID = UUID(), scheduledDate: Date, isCompleted: Bool = false) {
        self.id = id
        self.scheduledDate = scheduledDate
        self.isCompleted = isCompleted
    }
}

// MARK: - Metric Display Info

struct MetricDisplayInfo {
    let title: String
    let icon: String
    let unit: String
    let color: MetricColor
    let description: String
    let normalRange: String
    let targetValue: Double
}

enum MetricColor {
    case blue
    case green
    case orange
    case purple
    case red
    case teal
    
    var gradientColors: (Color, Color) {
        switch self {
        case .blue:
            return (Color(red: 0.2, green: 0.6, blue: 1.0), Color(red: 0.4, green: 0.7, blue: 1.0))
        case .green:
            return (Color(red: 0.2, green: 0.8, blue: 0.4), Color(red: 0.4, green: 0.9, blue: 0.6))
        case .orange:
            return (Color(red: 1.0, green: 0.6, blue: 0.2), Color(red: 1.0, green: 0.7, blue: 0.4))
        case .purple:
            return (Color(red: 0.6, green: 0.4, blue: 0.9), Color(red: 0.7, green: 0.5, blue: 1.0))
        case .red:
            return (Color(red: 1.0, green: 0.3, blue: 0.3), Color(red: 1.0, green: 0.5, blue: 0.5))
        case .teal:
            return (Color(red: 0.2, green: 0.8, blue: 0.8), Color(red: 0.4, green: 0.9, blue: 0.9))
        }
    }
    
    var solidColor: Color {
        switch self {
        case .blue:
            return Color(red: 0.2, green: 0.6, blue: 1.0)
        case .green:
            return Color(red: 0.2, green: 0.8, blue: 0.4)
        case .orange:
            return Color(red: 1.0, green: 0.6, blue: 0.2)
        case .purple:
            return Color(red: 0.6, green: 0.4, blue: 0.9)
        case .red:
            return Color(red: 1.0, green: 0.3, blue: 0.3)
        case .teal:
            return Color(red: 0.2, green: 0.8, blue: 0.8)
        }
    }
}

extension MetricType {
    var displayInfo: MetricDisplayInfo {
        switch self {
        case .hba1c:
            return MetricDisplayInfo(
                title: "HbA1c Level",
                icon: "drop.fill",
                unit: "%",
                color: .blue,
                description: "HbA1c measures your average blood sugar levels over the past 2-3 months. It's the gold standard for tracking diabetes management and reversal progress. Normal is below 5.7%, prediabetes is 5.7-6.4%, and diabetes is 6.5% or higher.",
                normalRange: "Normal: <5.7%, Prediabetes: 5.7-6.4%, Diabetes: ≥6.5%",
                targetValue: 5.7
            )
        case .fastingBloodGlucose:
            return MetricDisplayInfo(
                title: "Fasting Blood Glucose",
                icon: "waveform.path.ecg",
                unit: "mg/dL",
                color: .green,
                description: "Fasting Blood Glucose (FBG) is your blood sugar level after not eating for at least 8 hours, typically measured in the morning. Normal is 70-99 mg/dL, prediabetes is 100-125 mg/dL, and diabetes is 126 mg/dL or higher.",
                normalRange: "Normal: 70-99 mg/dL, Prediabetes: 100-125 mg/dL, Diabetes: ≥126 mg/dL",
                targetValue: 99
            )
        case .postprandialGlucose:
            return MetricDisplayInfo(
                title: "Postprandial Glucose",
                icon: "fork.knife",
                unit: "mg/dL",
                color: .orange,
                description: "Postprandial Glucose (PPG) is your blood sugar level 2 hours after eating. It shows how well your body processes food. Normal is below 140 mg/dL, prediabetes is 140-199 mg/dL, and diabetes is 200 mg/dL or higher.",
                normalRange: "Normal: <140 mg/dL, Prediabetes: 140-199 mg/dL, Diabetes: ≥200 mg/dL",
                targetValue: 140
            )
        case .weight:
            return MetricDisplayInfo(
                title: "Weight",
                icon: "scalemass.fill",
                unit: "lbs",
                color: .purple,
                description: "Weight management is crucial for diabetes reversal. Even a 5-10% weight loss can significantly improve blood sugar control and reduce insulin resistance. Sustainable weight loss combines healthy eating, regular activity, and lifestyle changes.",
                normalRange: "Target: 5-10% weight loss",
                targetValue: 0 // Will be calculated based on starting weight
            )
        case .sleepQuality:
            return MetricDisplayInfo(
                title: "Sleep Quality",
                icon: "moon.stars.fill",
                unit: "/10",
                color: .blue,
                description: "Sleep quality affects insulin sensitivity and blood sugar regulation. Poor sleep increases cortisol and insulin resistance. Aim for 7-9 hours of quality sleep per night with consistent sleep and wake times for optimal diabetes management.",
                normalRange: "Target: 7-9 hours of quality sleep",
                targetValue: 8.0
            )
        case .stressLevel:
            return MetricDisplayInfo(
                title: "Stress Level",
                icon: "brain.head.profile",
                unit: "/10",
                color: .red,
                description: "Stress triggers cortisol release, which raises blood sugar levels and increases insulin resistance. Managing stress through meditation, exercise, deep breathing, and healthy coping strategies is essential for diabetes reversal and overall health.",
                normalRange: "Lower is better",
                targetValue: 3.0
            )
        case .lifestyleAdherence:
            return MetricDisplayInfo(
                title: "Lifestyle Adherence",
                icon: "waveform.path.ecg",
                unit: "%",
                color: .teal,
                description: "Lifestyle adherence measures how well you follow healthy habits including regular exercise, consistent sleep schedule, stress management, and daily movement. Higher adherence is strongly linked to successful diabetes reversal and long-term health.",
                normalRange: "Target: 90%+ adherence",
                targetValue: 90.0
            )
        case .dietAdherence:
            return MetricDisplayInfo(
                title: "Diet Adherence",
                icon: "applelogo",
                unit: "%",
                color: .green,
                description: "Diet adherence tracks how consistently you follow nutritional guidelines including limiting refined carbs, choosing whole foods, eating adequate protein and healthy fats, and maintaining portion control. Nutrition is the foundation of diabetes reversal.",
                normalRange: "Target: 90%+ adherence",
                targetValue: 90.0
            )
        case .steps:
            return MetricDisplayInfo(
                title: "Steps",
                icon: "figure.walk",
                unit: "",
                color: .blue,
                description: "Daily step count is a key indicator of physical activity. Regular walking and movement help improve insulin sensitivity, lower blood sugar levels, and support weight management. Aim for at least 10,000 steps per day for optimal health benefits.",
                normalRange: "Target: 10,000+ steps per day",
                targetValue: 10000.0
            )
        }
    }
}

