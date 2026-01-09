//
//  DailyGoalsManager.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import Foundation
import SwiftUI
import Combine

class DailyGoalsManager: ObservableObject {
    static let shared = DailyGoalsManager()
    
    @Published var todayGoals: [DailyGoal] = []
    @Published var userProgress: UserProgress = UserProgress()
    @Published var achievements: [Achievement] = []
    
    private let goalsKey = "daily_goals"
    private let progressKey = "user_progress"
    private let achievementsKey = "achievements"
    
    private init() {
        loadGoals()
        loadProgress()
        loadAchievements()
        initializeTodayGoals()
        checkAchievements()
    }
    
    // MARK: - Goals Management
    
    func initializeTodayGoals() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Check if we already have goals for today
        if todayGoals.contains(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
            // Goals already exist for today
            return
        }
        
        // Remove old goals (not from today)
        todayGoals = todayGoals.filter { calendar.isDate($0.date, inSameDayAs: today) }
        
        // Create default goals for today
        let fastingGoal = DailyGoal(
            type: .fastingWindow,
            title: "Complete Fasting Window",
            subtitle: "16:8 Intermittent Fasting",
            targetValue: 16.0, // 16 hours
            currentValue: 0,
            xpReward: 50
        )
        
        let stepsGoal = DailyGoal(
            type: .dailySteps,
            title: "Daily Steps Goal",
            subtitle: "Walk 8,000 steps today",
            targetValue: 8000,
            currentValue: 0,
            xpReward: 30
        )
        
        let bloodSugarGoal = DailyGoal(
            type: .logBloodSugar,
            title: "Log Blood Sugar",
            subtitle: "Check and log your levels",
            targetValue: 1.0, // 1 = completed
            currentValue: 0,
            xpReward: 20
        )
        
        todayGoals = [fastingGoal, stepsGoal, bloodSugarGoal]
        saveGoals()
    }
    
    func updateGoalProgress(_ goalId: UUID, value: Double) {
        if let index = todayGoals.firstIndex(where: { $0.id == goalId }) {
            todayGoals[index].currentValue = value
            
            // Check if goal is completed
            if !todayGoals[index].isCompleted && todayGoals[index].currentValue >= todayGoals[index].targetValue {
                todayGoals[index].isCompleted = true
                awardXP(todayGoals[index].xpReward)
            }
            
            saveGoals()
        }
    }
    
    func completeGoal(_ goalId: UUID) {
        if let index = todayGoals.firstIndex(where: { $0.id == goalId }) {
            todayGoals[index].isCompleted = true
            todayGoals[index].currentValue = todayGoals[index].targetValue
            
            if !todayGoals[index].isCompleted {
                awardXP(todayGoals[index].xpReward)
            }
            
            saveGoals()
        }
    }
    
    // MARK: - XP & Progress
    
    func awardXP(_ amount: Int) {
        userProgress.addXP(amount)
        userProgress.updateStreak()
        saveProgress()
        checkAchievements()
    }
    
    // MARK: - Achievements
    
    func checkAchievements() {
        // Check streak achievements
        if userProgress.currentStreak >= 7 {
            unlockAchievement(.streak7)
        }
        if userProgress.currentStreak >= 30 {
            unlockAchievement(.streak30)
        }
        if userProgress.currentStreak >= 100 {
            unlockAchievement(.streak100)
        }
        
        // Check level achievements
        if userProgress.currentLevel >= 5 {
            unlockAchievement(.level5)
        }
        if userProgress.currentLevel >= 10 {
            unlockAchievement(.level10)
        }
        
        saveAchievements()
    }
    
    private func unlockAchievement(_ type: AchievementType) {
        if let index = achievements.firstIndex(where: { $0.type == type }) {
            if !achievements[index].isUnlocked {
                achievements[index].isUnlocked = true
                achievements[index].unlockedDate = Date()
            }
        } else {
            // Create new achievement
            let achievement = Achievement(
                type: type,
                title: getAchievementTitle(for: type),
                icon: getAchievementIcon(for: type),
                isUnlocked: true,
                unlockedDate: Date()
            )
            achievements.append(achievement)
        }
    }
    
    private func getAchievementTitle(for type: AchievementType) -> String {
        switch type {
        case .streak7: return "7-Day Streak"
        case .streak30: return "30-Day Goal"
        case .streak100: return "100-Day Streak"
        case .hba1cDrop: return "HbA1c Drop"
        case .weightLoss: return "Weight Loss"
        case .level5: return "Level 5"
        case .level10: return "Level 10"
        case .perfectWeek: return "Perfect Week"
        }
    }
    
    private func getAchievementIcon(for type: AchievementType) -> String {
        switch type {
        case .streak7, .streak30, .streak100, .perfectWeek: return "flame.fill"
        case .hba1cDrop: return "star.fill"
        case .weightLoss, .level5, .level10: return "trophy.fill"
        }
    }
    
    // MARK: - Sync with HealthKit
    
    func syncStepsFromHealthKit() {
        let healthKitManager = HealthKitManager.shared
        healthKitManager.readStepCount { [weak self] steps, error in
            guard let steps = steps else { return }
            
            if let stepsGoal = self?.todayGoals.first(where: { $0.type == .dailySteps }) {
                self?.updateGoalProgress(stepsGoal.id, value: steps)
            }
        }
    }
    
    // MARK: - Persistence
    
    private func saveGoals() {
        if let encoded = try? JSONEncoder().encode(todayGoals) {
            UserDefaults.standard.set(encoded, forKey: goalsKey)
        }
    }
    
    private func loadGoals() {
        if let data = UserDefaults.standard.data(forKey: goalsKey),
           let decoded = try? JSONDecoder().decode([DailyGoal].self, from: data) {
            todayGoals = decoded
        }
    }
    
    private func saveProgress() {
        if let encoded = try? JSONEncoder().encode(userProgress) {
            UserDefaults.standard.set(encoded, forKey: progressKey)
        }
    }
    
    private func loadProgress() {
        if let data = UserDefaults.standard.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode(UserProgress.self, from: data) {
            userProgress = decoded
        }
    }
    
    private func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: achievementsKey)
        }
    }
    
    private func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = decoded
        } else {
            // Initialize default achievements
            achievements = [
                Achievement(type: .streak7, title: "7-Day Streak", icon: "flame.fill"),
                Achievement(type: .hba1cDrop, title: "HbA1c Drop", icon: "star.fill"),
                Achievement(type: .streak30, title: "30-Day Goal", icon: "trophy.fill")
            ]
        }
    }
}

