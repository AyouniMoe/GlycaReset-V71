//
//  Habits.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import Foundation
import SwiftUI

// MARK: - Habit Models

enum HabitType: String, Codable, CaseIterable {
    case lifestyle = "lifestyle"
    case diet = "diet"
    
    var displayName: String {
        switch self {
        case .lifestyle: return "Lifestyle"
        case .diet: return "Diet"
        }
    }
    
    var icon: String {
        switch self {
        case .lifestyle: return "link.circle.fill"
        case .diet: return "fork.knife"
        }
    }
    
    var color: Color {
        switch self {
        case .lifestyle: return Color(red: 0.2, green: 0.8, blue: 0.4) // Green
        case .diet: return Color(red: 1.0, green: 0.6, blue: 0.2) // Orange
        }
    }
}

struct Habit: Codable, Identifiable, Hashable {
    let id: UUID
    var title: String
    var description: String
    let type: HabitType
    var simplifiedSteps: [SimplifiedStep]?
    var isPublished: Bool
    let createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), title: String, description: String, type: HabitType, simplifiedSteps: [SimplifiedStep]? = nil, isPublished: Bool = false, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.simplifiedSteps = simplifiedSteps
        self.isPublished = isPublished
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct SimplifiedStep: Codable, Identifiable, Hashable {
    let id: UUID
    var title: String
    var description: String
    var isCompleted: Bool
    let order: Int
    
    init(id: UUID = UUID(), title: String, description: String, isCompleted: Bool = false, order: Int) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.order = order
    }
}

struct PublishedHabit: Codable, Identifiable {
    let id: UUID
    let habitId: UUID
    let authorUsername: String
    let title: String
    let description: String
    let type: HabitType
    let simplifiedSteps: [SimplifiedStep]?
    let helpfulRatings: Int
    let notHelpfulRatings: Int
    let publishedAt: Date
    
    var helpfulPercentage: Double {
        let total = helpfulRatings + notHelpfulRatings
        guard total > 0 else { return 0 }
        return Double(helpfulRatings) / Double(total) * 100
    }
}

struct CommunityRating: Codable {
    let habitId: UUID
    let userId: String
    let isHelpful: Bool
    let ratedAt: Date
}

