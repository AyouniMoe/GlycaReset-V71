//
//  ModuleTestView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct ModuleTestView: View {
    let module: LearningModule
    @ObservedObject var learningManager: LearningManager
    @Environment(\.dismiss) var dismiss
    
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswerIndex: Int?
    @State private var showFeedback = false
    @State private var score = 0
    @State private var xpEarned = 0
    @State private var showResults = false
    
    private var questions: [Question] {
        learningManager.getTestQuestions(for: module.id) ?? []
    }
    
    private var currentQuestion: Question? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    private var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex + 1) / Double(questions.count)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.95, green: 0.96, blue: 0.98)
                    .ignoresSafeArea()
                
                if showResults {
                    TestResultsView(
                        score: score,
                        totalQuestions: questions.count,
                        xpEarned: xpEarned,
                        onClose: {
                            dismiss()
                        }
                    )
                } else if let question = currentQuestion {
                    ScrollView {
                        VStack(spacing: 0) {
                            // Progress Section
                            VStack(spacing: 12) {
                                Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                
                                // Progress Bar
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 6)
                                        
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
                                            .frame(width: geometry.size.width * CGFloat(progress), height: 6)
                                    }
                                }
                                .frame(height: 6)
                                
                                // Score and XP
                                HStack {
                                    Text("SCORE: \(score)/\(questions.count)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.white)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(Color.black, lineWidth: 1)
                                                )
                                        )
                                    
                                    Spacer()
                                    
                                    Text("\(xpEarned) XP")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(Color(red: 1.0, green: 0.6, blue: 0.2))
                                                .overlay(
                                                    Capsule()
                                                        .stroke(Color.red, lineWidth: 1)
                                                )
                                        )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 30)
                            
                            // Question Card
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Question")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Text(question.text)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineSpacing(4)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(24)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.6, green: 0.4, blue: 0.9),
                                        Color(red: 0.2, green: 0.6, blue: 1.0)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                            
                            // Answer Options
                            VStack(spacing: 12) {
                                ForEach(0..<question.options.count, id: \.self) { index in
                                    AnswerOptionButton(
                                        option: question.options[index],
                                        optionLetter: String(Character(UnicodeScalar(65 + index)!)), // A, B, C, D
                                        isSelected: selectedAnswerIndex == index,
                                        isCorrect: index == question.correctAnswerIndex,
                                        showFeedback: showFeedback,
                                        onTap: {
                                            if !showFeedback {
                                                selectedAnswerIndex = index
                                                checkAnswer(selectedIndex: index, correctIndex: question.correctAnswerIndex)
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                            
                            // Feedback Message
                            if showFeedback, let selectedIndex = selectedAnswerIndex {
                                FeedbackCard(
                                    isCorrect: selectedIndex == question.correctAnswerIndex,
                                    explanation: getExplanation(for: question, isCorrect: selectedIndex == question.correctAnswerIndex)
                                )
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                            }
                            
                            // Next Question Button
                            if showFeedback {
                                Button(action: {
                                    nextQuestion()
                                }) {
                                    Text(currentQuestionIndex < questions.count - 1 ? "NEXT QUESTION" : "VIEW RESULTS")
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
                                .padding(.bottom, 20)
                            }
                        }
                    }
                }
            }
            .navigationTitle(module.title)
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
    
    private func checkAnswer(selectedIndex: Int, correctIndex: Int) {
        showFeedback = true
        
        if selectedIndex == correctIndex {
            score += 1
            xpEarned += 20 // 20 XP per correct answer
        }
    }
    
    private func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswerIndex = nil
            showFeedback = false
        } else {
            // Test completed
            let finalScore = Double(score) / Double(questions.count)
            learningManager.completeTest(
                Test(moduleId: module.id, questions: questions, isCompleted: true, score: finalScore),
                score: finalScore
            )
            
            // Award bonus XP based on score
            if finalScore >= 0.8 {
                xpEarned += finalScore == 1.0 ? 50 : 30 // Perfect score bonus
            }
            
            showResults = true
        }
    }
    
    private func getExplanation(for question: Question, isCorrect: Bool) -> String {
        if let explanation = question.explanation {
            return isCorrect
                ? "Correct! \(explanation)"
                : "Not quite right. \(explanation)"
        }
        
        return isCorrect
            ? "Great job! You got it right."
            : "Not quite right. Review the lesson material to understand this concept better."
    }
}

// MARK: - Answer Option Button

struct AnswerOptionButton: View {
    let option: String
    let optionLetter: String
    let isSelected: Bool
    let isCorrect: Bool
    let showFeedback: Bool
    let onTap: () -> Void
    
    private var borderColor: Color {
        if showFeedback {
            if isSelected {
                return isCorrect ? Color(red: 0.2, green: 0.8, blue: 0.4) : Color.red
            } else if isCorrect {
                return Color(red: 0.2, green: 0.8, blue: 0.4)
            }
        }
        return Color.gray.opacity(0.3)
    }
    
    private var backgroundColor: Color {
        if showFeedback {
            if isSelected {
                return isCorrect ? Color(red: 0.9, green: 0.98, blue: 0.9) : Color(red: 1.0, green: 0.9, blue: 0.9)
            } else if isCorrect {
                return Color(red: 0.9, green: 0.98, blue: 0.9)
            }
        }
        return Color.white
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Option Letter
                ZStack {
                    Circle()
                        .fill(borderColor.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Text(optionLetter)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(borderColor)
                }
                
                // Option Text
                Text(option)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Feedback Icon
                if showFeedback {
                    if isSelected {
                        Image(systemName: isCorrect ? "checkmark" : "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(borderColor)
                    } else if isCorrect {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(borderColor)
                    }
                }
            }
            .padding(16)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 2)
            )
            .cornerRadius(12)
        }
        .disabled(showFeedback)
    }
}

// MARK: - Feedback Card

struct FeedbackCard: View {
    let isCorrect: Bool
    let explanation: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(isCorrect ? Color(red: 0.2, green: 0.8, blue: 0.4) : Color(red: 1.0, green: 0.6, blue: 0.2))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(isCorrect ? "Correct!" : "Not quite right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                
                Text(explanation)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .lineSpacing(4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCorrect ? Color(red: 0.9, green: 0.98, blue: 0.9) : Color(red: 1.0, green: 0.95, blue: 0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isCorrect ? Color(red: 0.2, green: 0.8, blue: 0.4) : Color(red: 1.0, green: 0.6, blue: 0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Test Results View

struct TestResultsView: View {
    let score: Int
    let totalQuestions: Int
    let xpEarned: Int
    let onClose: () -> Void
    
    private var percentage: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(score) / Double(totalQuestions)
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.96, blue: 0.98)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Result Icon
                Image(systemName: percentage >= 0.8 ? "trophy.fill" : "star.fill")
                    .font(.system(size: 60))
                    .foregroundColor(percentage >= 0.8 ? Color(red: 1.0, green: 0.6, blue: 0.2) : Color(red: 0.6, green: 0.4, blue: 0.9))
                
                // Score
                Text("\(score)/\(totalQuestions)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.black)
                
                Text("\(Int(percentage * 100))%")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.gray)
                
                // XP Earned
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                    
                    Text("\(xpEarned) XP Earned")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                }
                
                // Message
                Text(percentage >= 0.8 ? "Excellent work! You've mastered this module." : "Good effort! Review the lessons to improve your score.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                // Close Button
                Button(action: onClose) {
                    Text("CLOSE")
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
}

