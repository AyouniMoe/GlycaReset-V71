//
//  ImpactView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct ImpactView: View {
    @StateObject private var impactManager = ImpactManager.shared
    @State private var selectedType: ActivityType = .all
    
    var body: some View {
        ZStack {
            // Light blue-grey background
            Color(red: 0.95, green: 0.96, blue: 0.98)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Activity Impact")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("See how your actions drive results")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    
                    // Weekly Impact Summary Card
                    WeeklyImpactCard(summary: impactManager.getWeeklySummary())
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    
                    // Activity Type Tabs
                    ActivityTypeTabs(selectedType: $selectedType)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    
                    // Activity List
                    VStack(spacing: 16) {
                        ForEach(impactManager.getActivities(for: selectedType)) { activity in
                            ActivityImpactCard(activity: activity)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .onAppear {
            impactManager.syncFromOtherManagers()
        }
    }
}

// MARK: - Weekly Impact Card

struct WeeklyImpactCard: View {
    let summary: WeeklyImpactSummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("This Week's Impact")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // XP Badge
                Text("+\(summary.totalXP) XP")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.3))
                    )
            }
            
            // Progress Message
            Text(summary.progressMessage)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.6, green: 0.4, blue: 0.9),
                            Color(red: 0.2, green: 0.6, blue: 1.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            // Metrics Grid
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    MetricMiniCard(
                        icon: "waveform.path.ecg",
                        label: "Avg. Glucose",
                        value: "-\(Int(summary.avgGlucoseReduction))",
                        unit: "mg/dL reduced"
                    )
                    
                    MetricMiniCard(
                        icon: "scalemass.fill",
                        label: "Weight",
                        value: "-\(String(format: "%.1f", summary.weightLoss))",
                        unit: "lbs lost"
                    )
                }
                
                HStack(spacing: 12) {
                    MetricMiniCard(
                        icon: "applelogo",
                        label: "Activities",
                        value: "\(summary.activitiesLogged)",
                        unit: "logged this week"
                    )
                    
                    MetricMiniCard(
                        icon: "person.2.fill",
                        label: "Active Days",
                        value: "\(summary.activeDays)/\(summary.totalDays)",
                        unit: "days active"
                    )
                }
            }
        }
        .padding(24)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.8, blue: 0.4),
                    Color(red: 0.4, green: 0.9, blue: 0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
}

struct MetricMiniCard: View {
    let icon: String
    let label: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.9))
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.9))
                
                Text(unit)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white.opacity(0.2))
        .cornerRadius(12)
    }
}

// MARK: - Activity Type Tabs

struct ActivityTypeTabs: View {
    @Binding var selectedType: ActivityType
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(ActivityType.allCases, id: \.self) { type in
                Button(action: {
                    withAnimation {
                        selectedType = type
                    }
                }) {
                    Text(type.displayName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(selectedType == type ? .black : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedType == type ? Color.white : Color.clear)
                                .shadow(color: selectedType == type ? Color.black.opacity(0.1) : Color.clear, radius: 4, x: 0, y: 2)
                        )
                }
            }
        }
        .padding(4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Activity Impact Card

struct ActivityImpactCard: View {
    let activity: ActivityImpact
    
    private var timeString: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(activity.date) {
            formatter.dateFormat = "h:mm a"
            return "Today, \(formatter.string(from: activity.date))"
        } else if calendar.isDateInYesterday(activity.date) {
            formatter.dateFormat = "h:mm a"
            return "Yesterday, \(formatter.string(from: activity.date))"
        } else {
            formatter.dateFormat = "MMM d, h:mm a"
            return formatter.string(from: activity.date)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(alignment: .top, spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(activity.category.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: activity.category.icon)
                        .font(.system(size: 24))
                        .foregroundColor(activity.category.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(timeString)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Text(activity.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(activity.description)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // XP Badge
                Text("+\(activity.xpEarned) XP")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(activity.category.color)
                    )
            }
            
            // Impact Metrics
            if !activity.impacts.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(activity.impacts.enumerated()), id: \.offset) { index, impact in
                        HStack(spacing: 8) {
                            Image(systemName: "waveform.path")
                                .font(.system(size: 12))
                                .foregroundColor(impact.isPositive ? Color(red: 0.2, green: 0.8, blue: 0.4) : .gray)
                            
                            Text("\(impact.metric)")
                                .font(.system(size: 13))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Text("\(impact.isPositive ? "-" : "+")\(String(format: impact.unit == "%" ? "%.0f" : "%.1f", impact.value)) \(impact.unit)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(impact.isPositive ? Color(red: 0.2, green: 0.8, blue: 0.4) : .gray)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

