//
//  Learning.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import Foundation
import SwiftUI

// MARK: - Learning Models

struct LearningModule: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let lessons: [Lesson]
    let xpReward: Int
    let isLocked: Bool
    let unlockRequirement: String?
    let order: Int
    
    var completedLessonsCount: Int {
        return lessons.filter { $0.isCompleted }.count
    }
    
    var progress: Double {
        guard !lessons.isEmpty else { return 0 }
        return Double(completedLessonsCount) / Double(lessons.count)
    }
    
    var progressPercentage: Int {
        return Int(progress * 100)
    }
    
    var isCompleted: Bool {
        return completedLessonsCount == lessons.count
    }
    
    init(id: UUID = UUID(), title: String, description: String, icon: String, lessons: [Lesson], xpReward: Int, isLocked: Bool = false, unlockRequirement: String? = nil, order: Int) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.lessons = lessons
        self.xpReward = xpReward
        self.isLocked = isLocked
        self.unlockRequirement = unlockRequirement
        self.order = order
    }
}

struct Lesson: Codable, Identifiable {
    let id: UUID
    let title: String
    let content: String
    let duration: Int // in minutes
    var isCompleted: Bool
    let order: Int
    let keyPoints: [String] // Key takeaways
    let tips: [String] // Actionable tips
    let facts: [String] // Interesting facts
    
    init(id: UUID = UUID(), title: String, content: String, duration: Int, isCompleted: Bool = false, order: Int, keyPoints: [String] = [], tips: [String] = [], facts: [String] = []) {
        self.id = id
        self.title = title
        self.content = content
        self.duration = duration
        self.isCompleted = isCompleted
        self.order = order
        self.keyPoints = keyPoints
        self.tips = tips
        self.facts = facts
    }
}

struct Test: Codable, Identifiable {
    let id: UUID
    let moduleId: UUID
    let questions: [Question]
    var isCompleted: Bool
    var score: Double?
    
    init(id: UUID = UUID(), moduleId: UUID, questions: [Question], isCompleted: Bool = false, score: Double? = nil) {
        self.id = id
        self.moduleId = moduleId
        self.questions = questions
        self.isCompleted = isCompleted
        self.score = score
    }
}

struct Question: Codable, Identifiable {
    let id: UUID
    let text: String
    let options: [String]
    let correctAnswerIndex: Int
    let explanation: String?
    var selectedAnswerIndex: Int?
    
    init(id: UUID = UUID(), text: String, options: [String], correctAnswerIndex: Int, explanation: String? = nil, selectedAnswerIndex: Int? = nil) {
        self.id = id
        self.text = text
        self.options = options
        self.correctAnswerIndex = correctAnswerIndex
        self.explanation = explanation
        self.selectedAnswerIndex = selectedAnswerIndex
    }
}

// MARK: - Community Success Story

struct SuccessStory: Codable, Identifiable {
    let id: UUID
    let publishedHabitId: UUID
    let authorUsername: String
    let authorAvatar: String // Emoji or avatar identifier
    let remissionStatus: String // e.g., "REVERSED IN 8 MONTHS"
    let remissionDuration: String // e.g., "In remission for 2 years"
    let strategy: String
    let keyChanges: [String] // List of habits/changes
    let likes: Int
    let xpEarned: Int
    let starRating: Double // 0-5
    let adoptionCount: Int // Number of people who adopted this
    let publishedAt: Date
    
    init(id: UUID = UUID(), publishedHabitId: UUID, authorUsername: String, authorAvatar: String, remissionStatus: String, remissionDuration: String, strategy: String, keyChanges: [String], likes: Int, xpEarned: Int, starRating: Double, adoptionCount: Int, publishedAt: Date) {
        self.id = id
        self.publishedHabitId = publishedHabitId
        self.authorUsername = authorUsername
        self.authorAvatar = authorAvatar
        self.remissionStatus = remissionStatus
        self.remissionDuration = remissionDuration
        self.strategy = strategy
        self.keyChanges = keyChanges
        self.likes = likes
        self.xpEarned = xpEarned
        self.starRating = starRating
        self.adoptionCount = adoptionCount
        self.publishedAt = publishedAt
    }
}

