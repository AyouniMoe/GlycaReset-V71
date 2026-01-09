//
//  ImpactManager.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import Foundation
import SwiftUI
import Combine

class ImpactManager: ObservableObject {
    static let shared = ImpactManager()
    
    @Published var activities: [ActivityImpact] = []
    
    private let activitiesKey = "activity_impacts"
    
    private init() {
        loadActivities()
        syncFromOtherManagers()
    }
    
    // MARK: - Activity Management
    
    func addActivity(_ activity: ActivityImpact) {
        activities.append(activity)
        saveActivities()
    }
    
    func getActivities(for type: ActivityType) -> [ActivityImpact] {
        if type == .all {
            return activities.sorted { $0.date > $1.date }
        }
        return activities
            .filter { $0.category.activityType == type }
            .sorted { $0.date > $1.date }
    }
    
    func getWeeklySummary() -> WeeklyImpactSummary {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? now
        
        let weekActivities = activities.filter { calendar.isDate($0.date, equalTo: weekStart, toGranularity: .weekOfYear) }
        
        let totalXP = weekActivities.reduce(0) { $0 + $1.xpEarned }
        
        // Calculate average glucose reduction
        let glucoseImpacts = weekActivities.flatMap { $0.impacts.filter { $0.metric.contains("Glucose") || $0.metric.contains("Blood Sugar") } }
        let avgGlucoseReduction = glucoseImpacts.isEmpty ? 0 : glucoseImpacts.reduce(0) { $0 + $1.value } / Double(glucoseImpacts.count)
        
        // Calculate weight loss
        let weightImpacts = weekActivities.flatMap { $0.impacts.filter { $0.metric.contains("Weight") } }
        let weightLoss = weightImpacts.reduce(0) { $0 + $1.value }
        
        // Calculate active days
        let uniqueDays = Set(weekActivities.map { calendar.startOfDay(for: $0.date) })
        let activeDays = uniqueDays.count
        let totalDays = 7
        
        return WeeklyImpactSummary(
            weekStartDate: weekStart,
            totalXP: totalXP,
            avgGlucoseReduction: avgGlucoseReduction,
            weightLoss: abs(weightLoss), // Make positive
            activitiesLogged: weekActivities.count,
            activeDays: activeDays,
            totalDays: totalDays
        )
    }
    
    // MARK: - Sync from Other Managers
    
    func syncFromOtherManagers() {
        // Sync from DailyGoalsManager (completed goals)
        let goalsManager = DailyGoalsManager.shared
        let today = Date()
        let calendar = Calendar.current
        
        // Get completed goals from the last 7 days
        for goal in goalsManager.todayGoals {
            if goal.isCompleted && calendar.isDate(goal.date, inSameDayAs: today) {
                // Check if activity already exists
                if !activities.contains(where: { $0.title == goal.title && calendar.isDate($0.date, inSameDayAs: goal.date) }) {
                    let category = mapGoalTypeToCategory(goal.type)
                    let impacts = generateImpactsForGoal(goal)
                    
                    let activity = ActivityImpact(
                        category: category,
                        title: goal.title,
                        description: goal.subtitle,
                        date: goal.date,
                        xpEarned: goal.xpReward,
                        impacts: impacts
                    )
                    addActivity(activity)
                }
            }
        }
        
        // Sync from HabitsManager (completed habits)
        // Note: Habits completion tracking would need to be added to HabitsManager
        _ = HabitsManager.shared
    }
    
    private func mapGoalTypeToCategory(_ goalType: GoalType) -> ActivityCategory {
        switch goalType {
        case .fastingWindow:
            return .fasting
        case .mealLogging:
            return .meal
        case .dailySteps, .exercise:
            return .exercise
        case .logBloodSugar:
            return .bloodSugarLog
        case .waterIntake:
            return .water
        }
    }
    
    private func generateImpactsForGoal(_ goal: DailyGoal) -> [MetricImpact] {
        var impacts: [MetricImpact] = []
        
        switch goal.type {
        case .fastingWindow:
            // Fasting improves insulin sensitivity and can lower blood glucose
            impacts.append(MetricImpact(metric: "Blood Glucose", value: Double.random(in: 8...15), unit: "mg/dL"))
            impacts.append(MetricImpact(metric: "Weight", value: Double.random(in: 0.1...0.4), unit: "lbs"))
            
        case .dailySteps:
            // Steps improve glucose control
            let steps = goal.currentValue
            if steps >= 8000 {
                impacts.append(MetricImpact(metric: "Blood Glucose", value: Double.random(in: 5...12), unit: "mg/dL"))
            }
            
        case .logBloodSugar:
            // Logging helps with awareness
            impacts.append(MetricImpact(metric: "Awareness", value: 10, unit: "%"))
            
        case .mealLogging:
            // Meal logging helps with better choices
            impacts.append(MetricImpact(metric: "Blood Glucose", value: Double.random(in: 10...20), unit: "mg/dL"))
            
        case .exercise:
            // Exercise improves insulin sensitivity
            impacts.append(MetricImpact(metric: "Blood Glucose", value: Double.random(in: 15...25), unit: "mg/dL"))
            impacts.append(MetricImpact(metric: "Insulin Sensitivity", value: Double.random(in: 5...10), unit: "%"))
            
        case .waterIntake:
            // Hydration helps with metabolism
            impacts.append(MetricImpact(metric: "Metabolism", value: Double.random(in: 2...5), unit: "%"))
        }
        
        return impacts
    }
    
    // MARK: - Create Sample Activities
    
    func createSampleActivities() {
        // Only create if no activities exist
        guard activities.isEmpty else { return }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Today's activities
        if let today8AM = calendar.date(bySettingHour: 8, minute: 30, second: 0, of: now) {
            activities.append(ActivityImpact(
                category: .fasting,
                title: "16:8 Intermittent Fasting",
                description: "Completed 16-hour fasting window",
                date: today8AM,
                xpEarned: 50,
                impacts: [
                    MetricImpact(metric: "Blood Glucose", value: 12, unit: "mg/dL"),
                    MetricImpact(metric: "Weight", value: 0.3, unit: "lbs")
                ]
            ))
        }
        
        if let today645AM = calendar.date(bySettingHour: 6, minute: 45, second: 0, of: now) {
            activities.append(ActivityImpact(
                category: .meditation,
                title: "15 min Meditation",
                description: "Mindful breathing and relaxation",
                date: today645AM,
                xpEarned: 25,
                impacts: [
                    MetricImpact(metric: "Blood Glucose", value: 3, unit: "mg/dL"),
                    MetricImpact(metric: "Stress Reduction", value: 15, unit: "%")
                ]
            ))
        }
        
        // Yesterday's activities
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           let yesterday1PM = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: yesterday) {
            activities.append(ActivityImpact(
                category: .meal,
                title: "Low-Carb Lunch",
                description: "Grilled chicken salad with avocado",
                date: yesterday1PM,
                xpEarned: 35,
                impacts: [
                    MetricImpact(metric: "Blood Glucose", value: 15, unit: "mg/dL")
                ]
            ))
        }
        
        saveActivities()
    }
    
    // MARK: - Persistence
    
    private func saveActivities() {
        if let encoded = try? JSONEncoder().encode(activities) {
            UserDefaults.standard.set(encoded, forKey: activitiesKey)
        }
    }
    
    private func loadActivities() {
        if let data = UserDefaults.standard.data(forKey: activitiesKey),
           let decoded = try? JSONDecoder().decode([ActivityImpact].self, from: data) {
            activities = decoded
        } else {
            // Create sample activities if none exist
            createSampleActivities()
        }
    }
}

