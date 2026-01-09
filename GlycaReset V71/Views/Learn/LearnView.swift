//
//  LearnView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct LearnView: View {
    @StateObject private var learningManager = LearningManager.shared
    @State private var showSuccessStories = false
    @State private var selectedModule: LearningModule?
    @State private var selectedLesson: Lesson?
    
    var body: some View {
        ZStack {
            // Light blue-grey background
            Color(red: 0.95, green: 0.96, blue: 0.98)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Learning Hub")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("Master your health, one lesson at a time")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    
                    // Community Success Stories Card
                    CommunityStoriesCard(
                        storyCount: learningManager.successStories.count,
                        onTap: {
                            showSuccessStories = true
                        }
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                    // Learning Progress Card
                    LearningProgressCard(learningManager: learningManager)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    
                    // Learning Modules
                    VStack(spacing: 20) {
                        ForEach(learningManager.modules.sorted(by: { $0.order < $1.order })) { module in
                            LearningModuleCard(
                                module: module,
                                learningManager: learningManager,
                                onContinue: {
                                    // Find next incomplete lesson
                                    if let nextLesson = module.lessons.sorted(by: { $0.order < $1.order }).first(where: { !$0.isCompleted }) {
                                        selectedModule = module
                                        selectedLesson = nextLesson
                                    }
                                },
                                onTakeTest: {
                                    selectedModule = module
                                }
                            )
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(isPresented: $showSuccessStories) {
            CommunitySuccessStoriesView()
        }
        .sheet(item: $selectedModule) { module in
            ModuleTestView(module: module, learningManager: learningManager)
        }
        .sheet(item: Binding(
            get: { selectedLesson.map { LessonWrapper(lesson: $0, moduleId: selectedModule?.id ?? UUID()) } },
            set: { selectedLesson = $0?.lesson }
        )) { wrapper in
            LessonDetailView(lesson: wrapper.lesson, moduleId: wrapper.moduleId, learningManager: learningManager)
        }
        .onAppear {
            // Sync success stories from published habits
            learningManager.syncSuccessStoriesFromPublishedHabits()
            // Unlock modules based on progress
            for module in learningManager.modules {
                if module.isLocked {
                    learningManager.unlockModule(module.id)
                }
            }
        }
    }
}

// MARK: - Community Stories Card

struct CommunityStoriesCard: View {
    let storyCount: Int
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 32))
                    .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Community Success Stories")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Learn from those who achieved remission")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // XP Badge
                Text("+50 XP")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color(red: 0.2, green: 0.8, blue: 0.4))
                    )
            }
            
            Button(action: onTap) {
                HStack {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 14))
                    
                    Text("VIEW SUCCESS STORIES (\(storyCount))")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 1)
                )
                .cornerRadius(8)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.9, green: 0.98, blue: 0.9))
        )
    }
}

// MARK: - Lesson Wrapper

struct LessonWrapper: Identifiable {
    let id = UUID()
    let lesson: Lesson
    let moduleId: UUID
}

// MARK: - Learning Progress Card

struct LearningProgressCard: View {
    @ObservedObject var learningManager: LearningManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Learning Progress")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "book.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Text("\(learningManager.overallProgressPercentage)% COMPLETE")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.6))
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.6, blue: 0.2),
                                    Color(red: 0.6, green: 0.4, blue: 0.9)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(learningManager.overallProgress), height: 8)
                }
            }
            .frame(height: 8)
            
            Text("\(learningManager.completedLessons) of \(learningManager.totalLessons) lessons completed • \(learningManager.totalXPEarned) XP earned")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(20)
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
    }
}

// MARK: - Learning Module Card

struct LearningModuleCard: View {
    let module: LearningModule
    @ObservedObject var learningManager: LearningManager
    let onContinue: () -> Void
    let onTakeTest: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(alignment: .top, spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(module.isLocked ? Color.gray.opacity(0.2) : (module.isCompleted ? Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.2) : Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.2)))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: module.icon)
                        .font(.system(size: 24))
                        .foregroundColor(module.isLocked ? .gray : (module.isCompleted ? Color(red: 0.2, green: 0.8, blue: 0.4) : Color(red: 0.2, green: 0.6, blue: 1.0)))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(module.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    HStack(spacing: 8) {
                        Text("\(module.lessons.count) lessons")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        if !module.isLocked {
                            Text("• \(module.completedLessonsCount) / \(module.lessons.count) completed")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
                
                // XP Badge
                if !module.isLocked {
                    Text("+\(module.xpReward) XP")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.6, green: 0.4, blue: 0.9))
                        )
                }
            }
            
            if module.isLocked {
                // Locked State
                Text(module.unlockRequirement ?? "Complete previous modules to unlock")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.top, 8)
            } else {
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
                                        Color(red: 1.0, green: 0.3, blue: 0.3),
                                        Color(red: 0.6, green: 0.4, blue: 0.9)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(module.progress), height: 6)
                    }
                }
                .frame(height: 6)
                
                // Lessons List
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(module.lessons.sorted(by: { $0.order < $1.order }).prefix(3)) { lesson in
                        HStack(spacing: 8) {
                            Image(systemName: lesson.isCompleted ? "checkmark.circle.fill" : "play.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(lesson.isCompleted ? Color(red: 0.2, green: 0.8, blue: 0.4) : Color(red: 0.2, green: 0.6, blue: 1.0))
                            
                            Text(lesson.title)
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                        }
                    }
                }
                .padding(.top, 8)
                
                // Action Buttons
                HStack(spacing: 12) {
                    if !module.isCompleted {
                        Button(action: onContinue) {
                            Text("Continue Learning")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.2, green: 0.6, blue: 1.0),
                                            Color(red: 0.4, green: 0.7, blue: 1.0)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(8)
                        }
                    }
                    
                    if module.isCompleted {
                        Button(action: onTakeTest) {
                            Text("TAKE THE TEST")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(module.isLocked ? Color.gray.opacity(0.1) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(module.isLocked ? Color.gray.opacity(0.2) : Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.3), lineWidth: 1)
                )
        )
    }
}

