//
//  HabitsView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct HabitsView: View {
    @StateObject private var habitsManager = HabitsManager.shared
    @State private var showAddHabit = false
    @State private var editingHabit: Habit?
    @State private var simplifyingHabit: Habit?
    @State private var showPublishConfirmation = false
    
    var body: some View {
        ZStack {
            // Light blue-grey background
            Color(red: 0.95, green: 0.96, blue: 0.98)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("My Habits Builder")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("Create your personalized reversal plan")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    
                    // Information Card
                    HabitsInfoCard()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    
                    // Summary Cards
                    HStack(spacing: 12) {
                        SummaryCard(
                            type: .lifestyle,
                            count: habitsManager.lifestyleHabitsCount
                        )
                        
                        SummaryCard(
                            type: .diet,
                            count: habitsManager.dietHabitsCount
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    
                    // Lifestyle Changes Section
                    HabitsSection(
                        title: "Lifestyle Changes",
                        type: .lifestyle,
                        habits: habitsManager.getHabits(for: .lifestyle),
                        habitsManager: habitsManager,
                        onAdd: {
                            editingHabit = nil
                            showAddHabit = true
                        },
                        onEdit: { habit in
                            editingHabit = habit
                            showAddHabit = true
                        },
                        onDelete: { habit in
                            habitsManager.deleteHabit(habit)
                        },
                        onSimplify: { habit in
                            simplifyingHabit = habit
                        }
                    )
                    .padding(.bottom, 30)
                    
                    // Diet Protocols Section
                    HabitsSection(
                        title: "Diet Protocols",
                        type: .diet,
                        habits: habitsManager.getHabits(for: .diet),
                        habitsManager: habitsManager,
                        onAdd: {
                            editingHabit = nil
                            showAddHabit = true
                        },
                        onEdit: { habit in
                            editingHabit = habit
                            showAddHabit = true
                        },
                        onDelete: { habit in
                            habitsManager.deleteHabit(habit)
                        },
                        onSimplify: { habit in
                            simplifyingHabit = habit
                        }
                    )
                    .padding(.bottom, 30)
                    
                    // Ready to Share Section
                    if habitsManager.hasUnpublishedHabits {
                        PublishCard(
                            habitsManager: habitsManager,
                            onPublish: {
                                showPublishConfirmation = true
                            }
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                    
                    // Bottom spacing for tab bar
                    Spacer()
                        .frame(height: 100)
                }
            }
        }
        .sheet(isPresented: $showAddHabit) {
            AddHabitView(
                habit: editingHabit,
                habitsManager: habitsManager,
                onSave: { habit in
                    if editingHabit != nil {
                        habitsManager.updateHabit(habit)
                    } else {
                        habitsManager.addHabit(habit)
                    }
                    showAddHabit = false
                    editingHabit = nil
                },
                onCancel: {
                    showAddHabit = false
                    editingHabit = nil
                }
            )
        }
        .sheet(item: $simplifyingHabit) { habit in
            SimplifyHabitView(
                habit: habit,
                habitsManager: habitsManager
            )
        }
        .alert("Publish Your Habits", isPresented: $showPublishConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Publish") {
                _ = habitsManager.publishHabits()
            }
        } message: {
            Text("Publish your habits to inspire others in the community and earn 100 XP!")
        }
    }
}

// MARK: - Info Card

struct HabitsInfoCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "pin.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 1.0))
                
                Text("Build Your Custom Plan")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
            }
            
            Text("Add lifestyle changes and diet protocols that work for you. Use the \"Simplify\" button to break down any habit into easier micro-steps. When you're ready, publish your habits to share with the community!")
                .font(.system(size: 14))
                .foregroundColor(.black)
                .lineSpacing(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Summary Card

struct SummaryCard: View {
    let type: HabitType
    let count: Int
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.system(size: 20))
                    .foregroundColor(type.color)
                
                Text(type.displayName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(type.color)
            }
            
            Text("\(count)")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(type.color)
            
            Text(type == .lifestyle ? "habits" : "protocols")
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(type.color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(type.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Habits Section

struct HabitsSection: View {
    let title: String
    let type: HabitType
    let habits: [Habit]
    let habitsManager: HabitsManager
    let onAdd: () -> Void
    let onEdit: (Habit) -> Void
    let onDelete: (Habit) -> Void
    let onSimplify: (Habit) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: type.icon)
                        .font(.system(size: 18))
                        .foregroundColor(type.color)
                    
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Button(action: onAdd) {
                    Text("+ ADD NEW")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.1))
                        )
                }
            }
            .padding(.horizontal, 20)
            
            if habits.isEmpty {
                EmptyHabitsCard(type: type, onAdd: onAdd)
                    .padding(.horizontal, 20)
            } else {
                ForEach(habits) { habit in
                    HabitCard(
                        habit: habit,
                        onEdit: { onEdit(habit) },
                        onDelete: { onDelete(habit) },
                        onSimplify: { onSimplify(habit) }
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                }
            }
        }
    }
}

// MARK: - Habit Card

struct HabitCard: View {
    let habit: Habit
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onSimplify: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(habit.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(habit.description)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineSpacing(4)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundColor(.red)
                    }
                }
            }
            
            Button(action: onSimplify) {
                HStack {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16))
                    
                    Text("SIMPLIFY THIS HABIT")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.6, green: 0.4, blue: 0.9),
                            Color(red: 1.0, green: 0.4, blue: 0.6)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

// MARK: - Empty Habits Card

struct EmptyHabitsCard: View {
    let type: HabitType
    let onAdd: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: type.icon)
                .font(.system(size: 40))
                .foregroundColor(type.color.opacity(0.5))
            
            Text("No \(type == .lifestyle ? "lifestyle habits" : "diet protocols") yet")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.gray)
            
            Button(action: onAdd) {
                Text("+ Add Your First \(type.displayName) Habit")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(type.color)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(type.color.opacity(0.1))
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Publish Card

struct PublishCard: View {
    @ObservedObject var habitsManager: HabitsManager
    let onPublish: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                
                Text("Ready to Share?")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
            }
            
            Text("Publish your habits to inspire others in the community and earn 100 XP!")
                .font(.system(size: 14))
                .foregroundColor(.black)
                .lineSpacing(4)
            
            Button(action: onPublish) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16))
                    
                    Text("PUBLISH MY HABITS (+100 XP)")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.2, green: 0.8, blue: 0.4),
                            Color(red: 0.4, green: 0.9, blue: 0.6)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.3), lineWidth: 1)
                )
        )
    }
}

