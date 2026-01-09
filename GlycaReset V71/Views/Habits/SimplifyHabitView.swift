//
//  SimplifyHabitView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct SimplifyHabitView: View {
    let habit: Habit
    @ObservedObject var habitsManager: HabitsManager
    @Environment(\.dismiss) var dismiss
    
    @State private var simplifiedSteps: [SimplifiedStep] = []
    @State private var isGenerating = false
    @State private var hasGenerated = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.95, green: 0.96, blue: 0.98)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Habit Info Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Simplifying:")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            Text(habit.title)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text(habit.description)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .lineSpacing(4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        if isGenerating {
                            // Loading State
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                
                                Text("AI is breaking down your habit into simple steps...")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        } else if hasGenerated && !simplifiedSteps.isEmpty {
                            // Simplified Steps
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                                    
                                    Text("Simplified Steps")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.black)
                                }
                                
                                Text("Break down your habit into these manageable micro-steps:")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                
                                ForEach(simplifiedSteps.sorted(by: { $0.order < $1.order })) { step in
                                    SimplifiedStepCard(step: step)
                                }
                            }
                            .padding(.horizontal, 20)
                        } else if hasGenerated && simplifiedSteps.isEmpty {
                            // Error State
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 40))
                                    .foregroundColor(.orange)
                                
                                Text("Unable to simplify this habit")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                                
                                Text("Try adding more details to your habit description.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        } else {
                            // Initial State
                            VStack(spacing: 16) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 50))
                                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                                
                                Text("Simplify Your Habit")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Text("Our AI will break down your habit into smaller, more manageable micro-steps that are easier to follow and build into your routine.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                                    .padding(.horizontal, 20)
                                
                                Button(action: {
                                    generateSimplifiedSteps()
                                }) {
                                    HStack {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 16))
                                        
                                        Text("GENERATE SIMPLIFIED STEPS")
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
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
                                .padding(.horizontal, 20)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        }
                        
                        // Save Button (if steps generated)
                        if hasGenerated && !simplifiedSteps.isEmpty {
                            Button(action: {
                                habitsManager.saveSimplifiedSteps(simplifiedSteps, for: habit.id)
                                dismiss()
                            }) {
                                Text("SAVE SIMPLIFIED STEPS")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
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
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationTitle("Simplify Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.black)
                }
            }
        }
    }
    
    private func generateSimplifiedSteps() {
        isGenerating = true
        hasGenerated = false
        
        habitsManager.simplifyHabit(habit) { steps in
            simplifiedSteps = steps
            isGenerating = false
            hasGenerated = true
        }
    }
}

struct SimplifiedStepCard: View {
    let step: SimplifiedStep
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Step Number
            ZStack {
                Circle()
                    .fill(Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Text("\(step.order)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(step.description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineSpacing(4)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

