//
//  GoalDetailView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct GoalDetailView: View {
    let goal: DailyGoal
    @ObservedObject var goalsManager: DailyGoalsManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Light blue-grey background
                Color(red: 0.95, green: 0.96, blue: 0.98)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Today's Progress Card
                        TodayProgressCard(goal: goal, goalsManager: goalsManager)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        
                        // Why This Matters Section
                        if !goal.type.displayInfo.whyItMatters.isEmpty {
                            InfoSection(
                                title: "Why This Matters",
                                icon: "lightbulb.fill",
                                items: goal.type.displayInfo.whyItMatters,
                                backgroundColor: Color(red: 0.92, green: 0.96, blue: 0.98),
                                iconColor: goal.type.displayInfo.iconColor
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        // What You Need To Do Section
                        if !goal.type.displayInfo.whatToDo.isEmpty {
                            InfoSection(
                                title: "What You Need To Do",
                                icon: "list.bullet",
                                items: goal.type.displayInfo.whatToDo,
                                backgroundColor: Color(red: 0.92, green: 0.96, blue: 0.98),
                                iconColor: goal.type.displayInfo.iconColor,
                                isNumbered: true
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        // Tips & Best Practices Section
                        if !goal.type.displayInfo.tips.isEmpty {
                            TipsSection(
                                title: "Tips & Best Practices",
                                items: goal.type.displayInfo.tips
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        
                        // Action Button (for Log Blood Sugar)
                        if goal.type == .logBloodSugar && !goal.isCompleted {
                            Button(action: {
                                goalsManager.completeGoal(goal.id)
                                dismiss()
                            }) {
                                Text("LOG BLOOD SUGAR NOW")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                goal.type.displayInfo.cardColor,
                                                goal.type.displayInfo.cardColor.opacity(0.8)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationTitle(goal.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
}

// MARK: - Today's Progress Card

struct TodayProgressCard: View {
    let goal: DailyGoal
    @ObservedObject var goalsManager: DailyGoalsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: goal.type.displayInfo.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                
                Text("TODAY'S PROGRESS")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.6))
            }
            
            // Progress Display
            progressDisplay
            
            HStack {
                Spacer()
                
                // XP Badge
                Text("+\(goal.xpReward) XP")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.3))
                    )
            }
            
            // Progress Bar
            if goal.type != .logBloodSugar || goal.isCompleted {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Progress")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.9))
                    
                    HStack {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.3))
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white)
                                    .frame(width: geometry.size.width * goal.progress, height: 8)
                            }
                        }
                        .frame(height: 8)
                        
                        Text("\(goal.progressPercentage)%")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, alignment: .trailing)
                    }
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    goal.type.displayInfo.cardColor,
                    goal.type.displayInfo.cardColor.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
    
    @ViewBuilder
    private var progressDisplay: some View {
        if goal.type == .fastingWindow {
            let hours = Int(goal.currentValue)
            let minutes = Int((goal.currentValue - Double(hours)) * 60)
            let targetHours = Int(goal.targetValue)
            
            HStack(alignment: .bottom, spacing: 4) {
                Text("\(hours)h \(minutes)m")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                Text("/\(targetHours)h")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.8))
            }
        } else if goal.type == .dailySteps {
            HStack(alignment: .bottom, spacing: 4) {
                Text(formatNumber(goal.currentValue))
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                Text("/ \(formatNumber(goal.targetValue)) steps")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.8))
            }
        } else {
            HStack(alignment: .bottom, spacing: 4) {
                Text(goal.isCompleted ? "Complete" : "Not logged")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                if goal.isCompleted {
                    Text("/ Complete")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
    }
    
    private func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}

// MARK: - Info Section

struct InfoSection: View {
    let title: String
    let icon: String
    let items: [String]
    let backgroundColor: Color
    let iconColor: Color
    var isNumbered: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
            }
            
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 12) {
                    if isNumbered {
                        ZStack {
                            Circle()
                                .fill(iconColor)
                                .frame(width: 24, height: 24)
                            
                            Text("\(index + 1)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(iconColor)
                    }
                    
                    Text(item)
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor)
        .cornerRadius(12)
    }
}

// MARK: - Tips Section

struct TipsSection: View {
    let title: String
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            
            ForEach(items, id: \.self) { tip in
                HStack(alignment: .top, spacing: 12) {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.6, blue: 0.2))
                        .frame(width: 6, height: 6)
                        .padding(.top, 6)
                    
                    Text(tip)
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 1.0, green: 0.95, blue: 0.8))
        .cornerRadius(12)
    }
}

