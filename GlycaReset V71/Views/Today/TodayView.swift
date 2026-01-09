//
//  TodayView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct TodayView: View {
    @StateObject private var goalsManager = DailyGoalsManager.shared
    @State private var selectedGoal: DailyGoal?
    @State private var currentUser: UserAccount?
    
    var body: some View {
        ZStack {
            // Light blue-grey background
            Color(red: 0.95, green: 0.96, blue: 0.98)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 12) {
                        // Greeting
                        HStack {
                            Text(getGreeting())
                                .font(.system(size: 18))
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            // Streak Badge
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                                
                                Text("\(goalsManager.userProgress.currentStreak) Day Streak")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.1))
                            )
                        }
                        
                        // Your Journey Title
                        Text("YOUR JOURNEY")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.4, blue: 0.6),
                                        Color(red: 0.6, green: 0.4, blue: 0.9)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        // Reversal Progress
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reversal Progress")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            HStack {
                                // Progress Bar
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 8)
                                        
                                        let progress = calculateProgress()
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color(red: 0.6, green: 0.4, blue: 0.9),
                                                        Color(red: 1.0, green: 0.6, blue: 0.2)
                                                    ],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(width: geometry.size.width * progress, height: 8)
                                    }
                                }
                                .frame(height: 8)
                                
                                // Level Badge
                                Text("Level \(goalsManager.userProgress.currentLevel)")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.1))
                                    )
                            }
                            
                            // XP Text
                            let xpText = getXPText()
                            Text(xpText)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                    
                    // Today's Focus Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Today's Focus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                        
                        ForEach(goalsManager.todayGoals) { goal in
                            GoalCard(goal: goal, goalsManager: goalsManager)
                                .padding(.horizontal, 20)
                                .onTapGesture {
                                    selectedGoal = goal
                                }
                        }
                    }
                    .padding(.bottom, 30)
                    
                    // Recent Achievements Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Achievements")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(goalsManager.achievements.prefix(3)) { achievement in
                                    AchievementCard(achievement: achievement)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(item: $selectedGoal) { goal in
            GoalDetailView(goal: goal, goalsManager: goalsManager)
        }
        .onAppear {
            loadCurrentUser()
            goalsManager.initializeTodayGoals()
            goalsManager.syncStepsFromHealthKit()
        }
    }
    
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = currentUser?.username ?? "there"
        
        if hour < 12 {
            return "Good Morning, \(name)!"
        } else if hour < 17 {
            return "Good Afternoon, \(name)!"
        } else {
            return "Good Evening, \(name)!"
        }
    }
    
    private func calculateProgress() -> Double {
        let progress = goalsManager.userProgress
        let currentLevelXP = progress.xpForCurrentLevel
        let totalNeeded = progress.xpToNextLevel
        
        guard totalNeeded > 0 else { return 0 }
        return Double(currentLevelXP) / Double(totalNeeded)
    }
    
    private func getXPText() -> String {
        let progress = goalsManager.userProgress
        let currentLevelXP = progress.xpForCurrentLevel
        let totalNeeded = progress.xpToNextLevel
        
        return "\(currentLevelXP) / \(totalNeeded) XP to next level"
    }
    
    private func loadCurrentUser() {
        currentUser = LocalAccountManager.shared.getCurrentUser()
    }
}

// MARK: - Goal Card

struct GoalCard: View {
    let goal: DailyGoal
    @ObservedObject var goalsManager: DailyGoalsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                // Icon
                ZStack {
                    Circle()
                        .fill(goal.type.displayInfo.iconColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: goal.type.displayInfo.icon)
                        .font(.system(size: 24))
                        .foregroundColor(goal.type.displayInfo.iconColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text(goal.subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // XP Badge
                Text("+\(goal.xpReward) XP")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(goal.type.displayInfo.iconColor)
                    )
            }
            
            // Progress Display
            if goal.type == .fastingWindow {
                let hours = Int(goal.currentValue)
                let minutes = Int((goal.currentValue - Double(hours)) * 60)
                let targetHours = Int(goal.targetValue)
                
                HStack(alignment: .bottom, spacing: 4) {
                    Text("\(hours)h \(minutes)m")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("/\(targetHours)h")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            } else if goal.type == .dailySteps {
                HStack(alignment: .bottom, spacing: 4) {
                    Text(formatSteps(goal.currentValue))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("/ \(formatSteps(goal.targetValue)) steps")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            } else {
                Text(goal.isCompleted ? "Complete" : "Not logged")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
            }
            
            // Progress Bar
            if goal.type != .logBloodSugar || goal.isCompleted {
                HStack {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.6, green: 0.4, blue: 0.9),
                                            Color(red: 1.0, green: 0.6, blue: 0.2)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * goal.progress, height: 8)
                        }
                    }
                    .frame(height: 8)
                    
                    Text("\(goal.progressPercentage)%")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                        .frame(width: 40, alignment: .trailing)
                }
            }
            
            Text("Tap to learn more")
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func formatSteps(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}

// MARK: - Achievement Card

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: achievement.icon)
                .font(.system(size: 40))
                .foregroundColor(achievement.isUnlocked ? achievement.displayInfo.color : .gray)
            
            Text(achievement.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(achievement.isUnlocked ? .black : .gray)
        }
        .frame(width: 100, height: 100)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

