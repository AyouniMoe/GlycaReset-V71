//
//  CommunitySuccessStoriesView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct CommunitySuccessStoriesView: View {
    @StateObject private var learningManager = LearningManager.shared
    @StateObject private var habitsManager = HabitsManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var simplifyingHabit: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.95, green: 0.96, blue: 0.98)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header Banner
                        CommunityStoriesBanner()
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        
                        // Success Stories
                        ForEach(learningManager.successStories) { story in
                            SuccessStoryCard(
                                story: story,
                                onLike: {
                                    learningManager.likeStory(story.id)
                                },
                                onAdopt: {
                                    learningManager.adoptStory(story.id)
                                },
                                onSimplify: { change in
                                    simplifyingHabit = change
                                }
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        if learningManager.successStories.isEmpty {
                            EmptyStoriesView()
                                .padding(.horizontal, 20)
                                .padding(.vertical, 60)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Success Stories")
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
        .onAppear {
            learningManager.syncSuccessStoriesFromPublishedHabits()
        }
    }
}

// MARK: - Community Stories Banner

struct CommunityStoriesBanner: View {
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 32))
                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Community Success Stories")
                    .font(.system(size: 18, weight: .bold))
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
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.9, green: 0.98, blue: 0.9))
        )
    }
}

// MARK: - Success Story Card

struct SuccessStoryCard: View {
    let story: SuccessStory
    let onLike: () -> Void
    let onAdopt: () -> Void
    let onSimplify: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // User Info and Remission Status
            HStack(alignment: .top) {
                // Avatar
                Text(story.authorAvatar)
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(story.authorUsername)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(story.remissionDuration)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Remission Badge
                Text(story.remissionStatus)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.black)
                            .overlay(
                                Capsule()
                                    .stroke(Color(red: 0.2, green: 0.8, blue: 0.4), lineWidth: 1)
                            )
                    )
            }
            
            // Strategy
            Text("Strategy: \(story.strategy)")
                .font(.system(size: 14))
                .foregroundColor(.black)
                .lineSpacing(4)
            
            // Key Changes
            VStack(alignment: .leading, spacing: 12) {
                Text("Key Changes That Worked")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                
                ForEach(story.keyChanges, id: \.self) { change in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                            
                            Text(change)
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                        }
                        
                        Button(action: {
                            onSimplify(change)
                        }) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 12))
                                
                                Text("SIMPLIFY THIS HABIT")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
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
                            .cornerRadius(8)
                        }
                    }
                }
            }
            .padding(.top, 8)
            
            Divider()
            
            // Engagement Stats
            HStack(spacing: 20) {
                // Likes
                HStack(spacing: 4) {
                    Image(systemName: "hand.thumbsup.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text("\(story.likes) likes")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                // Star Rating
                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Image(systemName: Double(index) < story.starRating ? "star.fill" : "star")
                            .font(.system(size: 12))
                            .foregroundColor(Double(index) < story.starRating ? Color(red: 1.0, green: 0.6, blue: 0.2) : .gray)
                    }
                    Text(String(format: "%.1f", story.starRating))
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                // Adoption Count
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text("\(story.adoptionCount) adopted")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // XP Earned
                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                    
                    Text("Earned \(story.xpEarned) XP")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                }
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: onLike) {
                    HStack {
                        Image(systemName: "hand.thumbsup")
                            .font(.system(size: 14))
                        
                        Text("Like")
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
                
                Button(action: onAdopt) {
                    HStack {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 14))
                        
                        Text("Adopt")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
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
                    .cornerRadius(8)
                }
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

// MARK: - Empty Stories View

struct EmptyStoriesView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "trophy")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No Success Stories Yet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.gray)
            
            Text("Be the first to share your success story by publishing your habits!")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

