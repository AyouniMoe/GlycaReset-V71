//
//  DailyGoals.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import Foundation
import SwiftUI

// MARK: - Daily Goal Models

enum GoalType: String, Codable {
    case fastingWindow = "fasting_window"
    case dailySteps = "daily_steps"
    case logBloodSugar = "log_blood_sugar"
    case mealLogging = "meal_logging"
    case exercise = "exercise"
    case waterIntake = "water_intake"
}

struct DailyGoal: Codable, Identifiable, Hashable {
    let id: UUID
    let type: GoalType
    let title: String
    let subtitle: String
    let targetValue: Double
    var currentValue: Double
    let xpReward: Int
    var isCompleted: Bool
    let date: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: DailyGoal, rhs: DailyGoal) -> Bool {
        lhs.id == rhs.id
    }
    
    init(id: UUID = UUID(), type: GoalType, title: String, subtitle: String, targetValue: Double, currentValue: Double = 0, xpReward: Int, isCompleted: Bool = false, date: Date = Date()) {
        self.id = id
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.xpReward = xpReward
        self.isCompleted = isCompleted
        self.date = date
    }
    
    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(1.0, currentValue / targetValue)
    }
    
    var progressPercentage: Int {
        return Int(progress * 100)
    }
}

// MARK: - User Progress & Gamification

struct UserProgress: Codable {
    var totalXP: Int
    var currentLevel: Int
    var xpToNextLevel: Int
    var currentStreak: Int
    var lastActivityDate: Date?
    
    init(totalXP: Int = 0, currentLevel: Int = 1, xpToNextLevel: Int = 1200, currentStreak: Int = 0, lastActivityDate: Date? = nil) {
        self.totalXP = totalXP
        self.currentLevel = currentLevel
        self.xpToNextLevel = xpToNextLevel
        self.currentStreak = currentStreak
        self.lastActivityDate = lastActivityDate
    }
    
    mutating func addXP(_ amount: Int) {
        totalXP += amount
        
        // Check for level up
        while totalXP >= xpToNextLevel {
            totalXP -= xpToNextLevel
            currentLevel += 1
            xpToNextLevel = calculateXPForLevel(currentLevel + 1)
        }
    }
    
    mutating func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastDate = lastActivityDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysSince = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if daysSince == 1 {
                // Consecutive day
                currentStreak += 1
            } else if daysSince > 1 {
                // Streak broken
                currentStreak = 1
            }
            // If daysSince == 0, same day, don't update
        } else {
            // First activity
            currentStreak = 1
        }
        
        lastActivityDate = today
    }
    
    private func calculateXPForLevel(_ level: Int) -> Int {
        // XP required increases with level
        return 1200 + (level - 1) * 200
    }
    
    var xpForCurrentLevel: Int {
        let previousLevelXP = calculateXPForLevel(currentLevel) - 200
        return totalXP - previousLevelXP
    }
}

// MARK: - Achievement Models

enum AchievementType: String, Codable {
    case streak7 = "streak_7"
    case streak30 = "streak_30"
    case streak100 = "streak_100"
    case hba1cDrop = "hba1c_drop"
    case weightLoss = "weight_loss"
    case level5 = "level_5"
    case level10 = "level_10"
    case perfectWeek = "perfect_week"
}

struct Achievement: Codable, Identifiable {
    let id: UUID
    let type: AchievementType
    let title: String
    let icon: String
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    init(id: UUID = UUID(), type: AchievementType, title: String, icon: String, isUnlocked: Bool = false, unlockedDate: Date? = nil) {
        self.id = id
        self.type = type
        self.title = title
        self.icon = icon
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate
    }
    
    var displayInfo: AchievementDisplayInfo {
        switch type {
        case .streak7:
            return AchievementDisplayInfo(
                color: Color(red: 1.0, green: 0.84, blue: 0.0),
                description: "Maintain a 7-day activity streak"
            )
        case .streak30:
            return AchievementDisplayInfo(
                color: Color.gray,
                description: "Maintain a 30-day activity streak"
            )
        case .streak100:
            return AchievementDisplayInfo(
                color: Color.gray,
                description: "Maintain a 100-day activity streak"
            )
        case .hba1cDrop:
            return AchievementDisplayInfo(
                color: Color(red: 0.2, green: 0.6, blue: 1.0),
                description: "Achieve a significant HbA1c reduction"
            )
        case .weightLoss:
            return AchievementDisplayInfo(
                color: Color.gray,
                description: "Lose 10% of your body weight"
            )
        case .level5:
            return AchievementDisplayInfo(
                color: Color.gray,
                description: "Reach level 5"
            )
        case .level10:
            return AchievementDisplayInfo(
                color: Color.gray,
                description: "Reach level 10"
            )
        case .perfectWeek:
            return AchievementDisplayInfo(
                color: Color.gray,
                description: "Complete all daily goals for 7 days"
            )
        }
    }
}

struct AchievementDisplayInfo {
    let color: Color
    let description: String
}

// MARK: - Goal Display Info

extension GoalType {
    var displayInfo: GoalDisplayInfo {
        switch self {
        case .fastingWindow:
            return GoalDisplayInfo(
                icon: "clock.fill",
                iconColor: Color(red: 0.2, green: 0.6, blue: 1.0),
                cardColor: Color(red: 0.2, green: 0.6, blue: 1.0),
                whyItMatters: [
                    "Intermittent fasting improves insulin sensitivity by giving your body extended breaks from processing food, allowing insulin levels to drop naturally.",
                    "During fasting, your body switches from burning glucose to burning stored fat, which helps reduce insulin resistance - the root cause of type 2 diabetes.",
                    "Studies show that 16:8 fasting can reduce HbA1c levels by 0.5-1.5% in just 12 weeks, comparable to some diabetes medications.",
                    "Fasting triggers autophagy, a cellular cleanup process that removes damaged cells and improves metabolic health."
                ],
                whatToDo: [
                    "Finish eating by 8:00 PM tonight and don't eat again until 12:00 PM tomorrow (16-hour fast, 8-hour eating window).",
                    "During your fasting window, drink plenty of water, black coffee (no sugar/cream), or plain tea.",
                    "Break your fast with a balanced meal containing protein, healthy fats, and fiber-rich vegetables.",
                    "Avoid breaking your fast with sugary foods or refined carbs - this can spike your blood sugar unnecessarily."
                ],
                tips: [
                    "Start your eating window with a protein-rich meal to stabilize blood sugar",
                    "Stay hydrated - aim for 8 glasses of water during your fasting period",
                    "If you feel lightheaded, it's okay to break your fast early while your body adjusts",
                    "Schedule your eating window to match your lifestyle and social commitments"
                ]
            )
        case .dailySteps:
            return GoalDisplayInfo(
                icon: "figure.walk",
                iconColor: Color(red: 0.2, green: 0.8, blue: 0.4),
                cardColor: Color(red: 0.2, green: 0.8, blue: 0.4),
                whyItMatters: [
                    "Walking improves insulin sensitivity immediately - a single 15-minute walk after meals can lower blood sugar by 20-30%.",
                    "Regular walking helps your muscles absorb glucose without needing insulin, directly addressing insulin resistance.",
                    "Studies show that 8,000 steps per day reduces diabetes risk by 40% and helps reverse type 2 diabetes when combined with diet changes.",
                    "Physical activity burns visceral fat (belly fat), which is strongly linked to insulin resistance and metabolic dysfunction."
                ],
                whatToDo: [
                    "Aim to complete 8,000 steps by the end of the day - track your progress throughout the day.",
                    "Take a 15-minute walk after each meal (breakfast, lunch, dinner) to help control post-meal blood sugar spikes.",
                    "Break it into chunks: morning walk (2,000 steps), lunch walk (2,000 steps), evening walk (2,000 steps), daily activities (2,000 steps).",
                    "Use stairs instead of elevators, park farther away, or take walking breaks every hour if you have a desk job."
                ],
                tips: [
                    "Post-meal walks are most effective - walk 15-30 minutes after eating",
                    "Wear comfortable shoes and track your progress with your phone or fitness tracker",
                    "Walking with a friend or listening to podcasts makes it more enjoyable",
                    "Even 2-3 minute walking breaks every hour can help manage blood sugar"
                ]
            )
        case .logBloodSugar:
            return GoalDisplayInfo(
                icon: "drop.fill",
                iconColor: Color(red: 0.6, green: 0.4, blue: 0.9),
                cardColor: Color(red: 0.6, green: 0.4, blue: 0.9),
                whyItMatters: [
                    "Regular monitoring helps you understand how different foods, activities, and stress affect your blood sugar levels.",
                    "Tracking patterns allows you to identify which meals spike your glucose and adjust your diet for better control.",
                    "Consistent logging provides data for you and your healthcare team to make informed decisions about your reversal plan.",
                    "Seeing your numbers improve over time is incredibly motivating and reinforces positive lifestyle changes."
                ],
                whatToDo: [
                    "Test your fasting blood sugar first thing in the morning before eating or drinking anything (target: 70-99 mg/dL).",
                    "Log your reading in the app along with any notes about sleep, stress, or unusual activities.",
                    "Optional: Test 2 hours after meals to see how different foods affect you (target: below 140 mg/dL).",
                    "Record the time, date, and any relevant context (before/after meal, stress level, exercise, etc.)."
                ],
                tips: [
                    "Test at the same time each day for consistent comparisons",
                    "Wash your hands with warm water before testing for accurate results",
                    "Keep your glucose meter and strips in a cool, dry place",
                    "Look for patterns over weeks, not daily fluctuations"
                ]
            )
        case .mealLogging:
            return GoalDisplayInfo(
                icon: "fork.knife",
                iconColor: Color(red: 1.0, green: 0.6, blue: 0.2),
                cardColor: Color(red: 1.0, green: 0.6, blue: 0.2),
                whyItMatters: [],
                whatToDo: [],
                tips: []
            )
        case .exercise:
            return GoalDisplayInfo(
                icon: "figure.run",
                iconColor: Color(red: 1.0, green: 0.3, blue: 0.3),
                cardColor: Color(red: 1.0, green: 0.3, blue: 0.3),
                whyItMatters: [],
                whatToDo: [],
                tips: []
            )
        case .waterIntake:
            return GoalDisplayInfo(
                icon: "drop.fill",
                iconColor: Color(red: 0.2, green: 0.7, blue: 1.0),
                cardColor: Color(red: 0.2, green: 0.7, blue: 1.0),
                whyItMatters: [],
                whatToDo: [],
                tips: []
            )
        }
    }
}

struct GoalDisplayInfo {
    let icon: String
    let iconColor: Color
    let cardColor: Color
    let whyItMatters: [String]
    let whatToDo: [String]
    let tips: [String]
}

