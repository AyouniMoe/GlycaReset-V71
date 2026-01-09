//
//  GamifiedLessonView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct GamifiedLessonView: View {
    let lesson: Lesson
    let moduleId: UUID
    @ObservedObject var learningManager: LearningManager
    @Environment(\.dismiss) var dismiss
    
    @State private var currentSection = 0
    @State private var isCompleted = false
    @State private var xpEarned = 0
    @State private var showCompletion = false
    
    private let sections: [String] = ["Overview", "Key Points", "Tips", "Facts"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.95, green: 0.96, blue: 0.98),
                        Color(red: 0.9, green: 0.95, blue: 1.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if showCompletion {
                    CompletionView(
                        lesson: lesson,
                        xpEarned: xpEarned,
                        onContinue: {
                            learningManager.completeLesson(lessonId: lesson.id, moduleId: moduleId)
                            dismiss()
                        }
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            // Progress Header
                            ProgressHeader(
                                lesson: lesson,
                                currentSection: currentSection,
                                totalSections: sections.count,
                                xpEarned: xpEarned
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 30)
                            
                            // Section Content
                            VStack(spacing: 24) {
                                if currentSection == 0 {
                                    OverviewSection(lesson: lesson)
                                } else if currentSection == 1 {
                                    KeyPointsSection(lesson: lesson)
                                } else if currentSection == 2 {
                                    LessonTipsSection(lesson: lesson)
                                } else if currentSection == 3 {
                                    FactsSection(lesson: lesson)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                            
                            // Navigation Buttons
                            HStack(spacing: 12) {
                                if currentSection > 0 {
                                    Button(action: {
                                        withAnimation {
                                            currentSection -= 1
                                        }
                                    }) {
                                        Text("PREVIOUS")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.black)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 14)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.black, lineWidth: 1)
                                            )
                                            .cornerRadius(12)
                                    }
                                }
                                
                                Button(action: {
                                    if currentSection < sections.count - 1 {
                                        withAnimation {
                                            currentSection += 1
                                            xpEarned += 5 // Award XP for each section
                                        }
                                    } else {
                                        // Complete lesson
                                        xpEarned += 20 // Bonus XP for completion
                                        withAnimation {
                                            showCompletion = true
                                        }
                                    }
                                }) {
                                    Text(currentSection < sections.count - 1 ? "NEXT" : "COMPLETE")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 0.6, green: 0.4, blue: 0.9),
                                                    Color(red: 0.2, green: 0.6, blue: 1.0)
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .navigationTitle(lesson.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
}

// MARK: - Progress Header

struct ProgressHeader: View {
    let lesson: Lesson
    let currentSection: Int
    let totalSections: Int
    let xpEarned: Int
    
    private var progress: Double {
        return Double(currentSection + 1) / Double(totalSections)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // XP Badge
            HStack {
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                    
                    Text("\(xpEarned) XP")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.1))
                )
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.6, green: 0.4, blue: 0.9),
                                    Color(red: 0.2, green: 0.6, blue: 1.0)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(progress), height: 8)
                }
            }
            .frame(height: 8)
            
            // Section Indicator
            Text("Section \(currentSection + 1) of \(totalSections)")
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Overview Section

struct OverviewSection: View {
    let lesson: Lesson
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "book.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 1.0))
                
                Text("Overview")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
            }
            
            Text(lesson.content)
                .font(.system(size: 16))
                .foregroundColor(.black)
                .lineSpacing(6)
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Key Points Section

struct KeyPointsSection: View {
    let lesson: Lesson
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "key.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                
                Text("Key Points")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
            }
            
            VStack(spacing: 16) {
                ForEach(Array(lesson.keyPoints.enumerated()), id: \.offset) { index, point in
                    KeyPointCard(number: index + 1, text: point)
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct KeyPointCard: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Text("\(number)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
            }
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.black)
                .lineSpacing(4)
        }
        .padding(16)
        .background(Color(red: 0.95, green: 0.95, blue: 0.98))
        .cornerRadius(12)
    }
}

// MARK: - Tips Section

struct LessonTipsSection: View {
    let lesson: Lesson
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                
                Text("Actionable Tips")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
            }
            
            VStack(spacing: 12) {
                ForEach(Array(lesson.tips.enumerated()), id: \.offset) { index, tip in
                    TipCard(text: tip)
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct TipCard: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.black)
                .lineSpacing(4)
        }
        .padding(16)
        .background(Color(red: 1.0, green: 0.95, blue: 0.9))
        .cornerRadius(12)
    }
}

// MARK: - Facts Section

struct FactsSection: View {
    let lesson: Lesson
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                
                Text("Did You Know?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
            }
            
            VStack(spacing: 12) {
                ForEach(Array(lesson.facts.enumerated()), id: \.offset) { index, fact in
                    FactCard(text: fact)
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct FactCard: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "star.fill")
                .font(.system(size: 16))
                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.black)
                .lineSpacing(4)
        }
        .padding(16)
        .background(Color(red: 0.9, green: 0.98, blue: 0.9))
        .cornerRadius(12)
    }
}

// MARK: - Completion View

struct CompletionView: View {
    let lesson: Lesson
    let xpEarned: Int
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Celebration Animation
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.6, green: 0.4, blue: 0.9),
                                Color(red: 0.2, green: 0.6, blue: 1.0)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text("Lesson Complete!")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)
            
            // XP Earned
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                
                Text("\(xpEarned) XP Earned")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
            }
            
            Text("Great job! You've completed \"\(lesson.title)\"")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: onContinue) {
                Text("CONTINUE")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.6, green: 0.4, blue: 0.9),
                                Color(red: 0.2, green: 0.6, blue: 1.0)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
}

