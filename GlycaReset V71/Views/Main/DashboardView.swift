//
//  DashboardView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct DashboardView: View {
    @State private var selectedTab: TabItem = .metrics
    
    enum TabItem {
        case metrics
        case today
        case habits
        case learn
        case impact
    }
    
    var body: some View {
        ZStack {
            // Main content based on selected tab
            Group {
                switch selectedTab {
                case .metrics:
                    MetricsView()
                case .today:
                    TodayView()
                case .habits:
                    HabitsView()
                case .learn:
                    LearnView()
                case .impact:
                    ImpactView()
                }
            }
            
            // Bottom navigation bar
            VStack {
                Spacer()
                BottomNavigationBar(selectedTab: $selectedTab)
            }
        }
    }
}

// MARK: - Bottom Navigation Bar

struct BottomNavigationBar: View {
    @Binding var selectedTab: DashboardView.TabItem
    
    var body: some View {
        HStack(spacing: 0) {
            TabButton(
                icon: "waveform.path.ecg",
                label: "METRICS",
                isSelected: selectedTab == .metrics
            ) {
                selectedTab = .metrics
            }
            
            TabButton(
                icon: "calendar",
                label: "TODAY",
                isSelected: selectedTab == .today
            ) {
                selectedTab = .today
            }
            
            TabButton(
                icon: "target",
                label: "HABITS",
                isSelected: selectedTab == .habits
            ) {
                selectedTab = .habits
            }
            
            TabButton(
                icon: "book",
                label: "LEARN",
                isSelected: selectedTab == .learn
            ) {
                selectedTab = .learn
            }
            
            TabButton(
                icon: "chart.line.uptrend.xyaxis",
                label: "IMPACT",
                isSelected: selectedTab == .impact
            ) {
                selectedTab = .impact
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -2)
    }
}

struct TabButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? Color(red: 1.0, green: 0.4, blue: 0.6) : .gray)
                
                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Color(red: 1.0, green: 0.4, blue: 0.6) : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(red: 1.0, green: 0.4, blue: 0.6).opacity(0.1) : Color.clear)
            )
        }
    }
}

// HabitsView is now in Views/Habits/HabitsView.swift

// LearnView is now in Views/Learn/LearnView.swift

// ImpactView is now in Views/Impact/ImpactView.swift
