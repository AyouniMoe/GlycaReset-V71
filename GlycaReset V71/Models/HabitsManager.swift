//
//  HabitsManager.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import Foundation
import SwiftUI
import Combine

class HabitsManager: ObservableObject {
    static let shared = HabitsManager()
    
    @Published var habits: [Habit] = []
    @Published var publishedHabits: [PublishedHabit] = []
    @Published var userRatings: [CommunityRating] = []
    
    private let habitsKey = "user_habits"
    private let publishedHabitsKey = "published_habits"
    private let ratingsKey = "community_ratings"
    
    private init() {
        loadHabits()
        loadPublishedHabits()
        loadRatings()
    }
    
    // MARK: - Habit Management
    
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        saveHabits()
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            var updatedHabit = habit
            updatedHabit.updatedAt = Date()
            habits[index] = updatedHabit
            saveHabits()
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        saveHabits()
    }
    
    func getHabits(for type: HabitType) -> [Habit] {
        return habits.filter { $0.type == type }.sorted { $0.createdAt > $1.createdAt }
    }
    
    var lifestyleHabitsCount: Int {
        return habits.filter { $0.type == .lifestyle }.count
    }
    
    var dietHabitsCount: Int {
        return habits.filter { $0.type == .diet }.count
    }
    
    var hasUnpublishedHabits: Bool {
        return habits.contains { !$0.isPublished }
    }
    
    // MARK: - AI Simplification
    
    func simplifyHabit(_ habit: Habit, completion: @escaping ([SimplifiedStep]) -> Void) {
        // Simulate AI processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let simplifiedSteps = self.generateSimplifiedSteps(for: habit)
            completion(simplifiedSteps)
        }
    }
    
    private func generateSimplifiedSteps(for habit: Habit) -> [SimplifiedStep] {
        // AI-powered simplification logic
        // This is a placeholder - in production, this would call an AI API
        
        let title = habit.title.lowercased()
        let description = habit.description.lowercased()
        
        var steps: [SimplifiedStep] = []
        
        // Analyze the habit and break it down into micro-steps
        if title.contains("walk") || description.contains("walk") {
            steps = [
                SimplifiedStep(title: "Set a daily reminder", description: "Add a reminder on your phone for your walk time", order: 1),
                SimplifiedStep(title: "Prepare your walking gear", description: "Lay out comfortable shoes and clothes the night before", order: 2),
                SimplifiedStep(title: "Start with 10 minutes", description: "Begin with just 10 minutes and gradually increase", order: 3),
                SimplifiedStep(title: "Track your progress", description: "Use the app to log your daily walks", order: 4),
                SimplifiedStep(title: "Build consistency", description: "Aim for 5 days a week, then increase to daily", order: 5)
            ]
        } else if title.contains("carb") || description.contains("carb") {
            steps = [
                SimplifiedStep(title: "Learn carb counting basics", description: "Understand that 1 serving = ~15g carbs", order: 1),
                SimplifiedStep(title: "Plan your dinner menu", description: "Choose protein, vegetables, and limit carbs to 30g", order: 2),
                SimplifiedStep(title: "Prepare low-carb alternatives", description: "Stock up on cauliflower rice, zucchini noodles", order: 3),
                SimplifiedStep(title: "Measure portions", description: "Use measuring cups or a food scale initially", order: 4),
                SimplifiedStep(title: "Track in the app", description: "Log your meals to build awareness", order: 5)
            ]
        } else if title.contains("fast") || description.contains("fast") {
            steps = [
                SimplifiedStep(title: "Start with 12 hours", description: "Begin with a 12-hour overnight fast", order: 1),
                SimplifiedStep(title: "Gradually extend", description: "Add 1 hour each week until you reach your goal", order: 2),
                SimplifiedStep(title: "Stay hydrated", description: "Drink water, black coffee, or tea during fasting", order: 3),
                SimplifiedStep(title: "Break fast mindfully", description: "Start with protein and healthy fats", order: 4),
                SimplifiedStep(title: "Listen to your body", description: "Adjust timing based on your schedule and energy", order: 5)
            ]
        } else {
            // Generic simplification
            steps = [
                SimplifiedStep(title: "Break it into smaller parts", description: "Identify the smallest first step you can take", order: 1),
                SimplifiedStep(title: "Set a specific time", description: "Schedule when you'll do this habit each day", order: 2),
                SimplifiedStep(title: "Create a trigger", description: "Link this habit to an existing routine", order: 3),
                SimplifiedStep(title: "Track your progress", description: "Use the app to monitor your consistency", order: 4),
                SimplifiedStep(title: "Celebrate small wins", description: "Acknowledge each day you complete the habit", order: 5)
            ]
        }
        
        return steps
    }
    
    func saveSimplifiedSteps(_ steps: [SimplifiedStep], for habitId: UUID) {
        if let index = habits.firstIndex(where: { $0.id == habitId }) {
            var updatedHabit = habits[index]
            updatedHabit.simplifiedSteps = steps
            updatedHabit.updatedAt = Date()
            habits[index] = updatedHabit
            saveHabits()
        }
    }
    
    // MARK: - Publishing
    
    func publishHabits() -> Bool {
        let unpublishedHabits = habits.filter { !$0.isPublished }
        guard !unpublishedHabits.isEmpty else { return false }
        
        let currentUser = LocalAccountManager.shared.getCurrentUser()
        let username = currentUser?.username ?? "Anonymous"
        
        for habit in unpublishedHabits {
            let publishedHabit = PublishedHabit(
                id: UUID(),
                habitId: habit.id,
                authorUsername: username,
                title: habit.title,
                description: habit.description,
                type: habit.type,
                simplifiedSteps: habit.simplifiedSteps,
                helpfulRatings: 0,
                notHelpfulRatings: 0,
                publishedAt: Date()
            )
            
            publishedHabits.append(publishedHabit)
            
            // Mark habit as published
            if let index = habits.firstIndex(where: { $0.id == habit.id }) {
                var updatedHabit = habit
                updatedHabit.isPublished = true
                habits[index] = updatedHabit
            }
        }
        
        saveHabits()
        savePublishedHabits()
        
        // Award XP for publishing
        DailyGoalsManager.shared.awardXP(100)
        
        return true
    }
    
    // MARK: - Community Ratings
    
    func rateHabit(_ habitId: UUID, isHelpful: Bool) {
        let currentUser = LocalAccountManager.shared.getCurrentUser()
        let userId = currentUser?.username ?? UUID().uuidString
        
        // Check if user already rated this habit
        if let existingRatingIndex = userRatings.firstIndex(where: { $0.habitId == habitId && $0.userId == userId }) {
            let oldRating = userRatings[existingRatingIndex]
            userRatings.remove(at: existingRatingIndex)
            
            // Update published habit rating
            if let index = publishedHabits.firstIndex(where: { $0.habitId == habitId }) {
                var habit = publishedHabits[index]
                if oldRating.isHelpful {
                    habit = PublishedHabit(
                        id: habit.id,
                        habitId: habit.habitId,
                        authorUsername: habit.authorUsername,
                        title: habit.title,
                        description: habit.description,
                        type: habit.type,
                        simplifiedSteps: habit.simplifiedSteps,
                        helpfulRatings: max(0, habit.helpfulRatings - 1),
                        notHelpfulRatings: habit.notHelpfulRatings,
                        publishedAt: habit.publishedAt
                    )
                } else {
                    habit = PublishedHabit(
                        id: habit.id,
                        habitId: habit.habitId,
                        authorUsername: habit.authorUsername,
                        title: habit.title,
                        description: habit.description,
                        type: habit.type,
                        simplifiedSteps: habit.simplifiedSteps,
                        helpfulRatings: habit.helpfulRatings,
                        notHelpfulRatings: max(0, habit.notHelpfulRatings - 1),
                        publishedAt: habit.publishedAt
                    )
                }
                publishedHabits[index] = habit
            }
        }
        
        // Add new rating
        let rating = CommunityRating(
            habitId: habitId,
            userId: userId,
            isHelpful: isHelpful,
            ratedAt: Date()
        )
        userRatings.append(rating)
        
        // Update published habit rating
        if let index = publishedHabits.firstIndex(where: { $0.habitId == habitId }) {
            var habit = publishedHabits[index]
            if isHelpful {
                habit = PublishedHabit(
                    id: habit.id,
                    habitId: habit.habitId,
                    authorUsername: habit.authorUsername,
                    title: habit.title,
                    description: habit.description,
                    type: habit.type,
                    simplifiedSteps: habit.simplifiedSteps,
                    helpfulRatings: habit.helpfulRatings + 1,
                    notHelpfulRatings: habit.notHelpfulRatings,
                    publishedAt: habit.publishedAt
                )
            } else {
                habit = PublishedHabit(
                    id: habit.id,
                    habitId: habit.habitId,
                    authorUsername: habit.authorUsername,
                    title: habit.title,
                    description: habit.description,
                    type: habit.type,
                    simplifiedSteps: habit.simplifiedSteps,
                    helpfulRatings: habit.helpfulRatings,
                    notHelpfulRatings: habit.notHelpfulRatings + 1,
                    publishedAt: habit.publishedAt
                )
            }
            publishedHabits[index] = habit
        }
        
        saveRatings()
        savePublishedHabits()
    }
    
    func getUserRating(for habitId: UUID) -> Bool? {
        let currentUser = LocalAccountManager.shared.getCurrentUser()
        let userId = currentUser?.username ?? UUID().uuidString
        return userRatings.first(where: { $0.habitId == habitId && $0.userId == userId })?.isHelpful
    }
    
    // MARK: - Persistence
    
    private func saveHabits() {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: habitsKey)
        }
    }
    
    private func loadHabits() {
        if let data = UserDefaults.standard.data(forKey: habitsKey),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        }
    }
    
    private func savePublishedHabits() {
        if let encoded = try? JSONEncoder().encode(publishedHabits) {
            UserDefaults.standard.set(encoded, forKey: publishedHabitsKey)
        }
    }
    
    private func loadPublishedHabits() {
        if let data = UserDefaults.standard.data(forKey: publishedHabitsKey),
           let decoded = try? JSONDecoder().decode([PublishedHabit].self, from: data) {
            publishedHabits = decoded
        }
    }
    
    private func saveRatings() {
        if let encoded = try? JSONEncoder().encode(userRatings) {
            UserDefaults.standard.set(encoded, forKey: ratingsKey)
        }
    }
    
    private func loadRatings() {
        if let data = UserDefaults.standard.data(forKey: ratingsKey),
           let decoded = try? JSONDecoder().decode([CommunityRating].self, from: data) {
            userRatings = decoded
        }
    }
}

