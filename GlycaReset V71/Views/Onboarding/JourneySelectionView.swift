//
//  JourneySelectionView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct JourneySelectionView: View {
    @ObservedObject var appState: AppStateViewModel
    @State private var selectedOption: JourneyType?
    
    var body: some View {
        ZStack {
            // Light blue-grey background
            Color(red: 0.95, green: 0.96, blue: 0.98)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress bar and step indicator
                VStack(spacing: 12) {
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background bar
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 4)
                            
                            // Progress fill (1/8 for step 1 - default, will be updated based on selection)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 1.0, green: 0.4, blue: 0.6), // Pink
                                            Color(red: 1.0, green: 0.6, blue: 0.2)  // Orange
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width / 8, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 30)
                    
                    // Step indicator
                    HStack {
                        Text("Step 1 of 8")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Heart icon
                ZStack {
                    Circle()
                        .fill(Color(red: 0.9, green: 0.8, blue: 1.0)) // Light purple
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.8)) // Dark blue
                }
                .padding(.bottom, 30)
                
                // Main title
                Text("Where are you in your journey?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 12)
                
                // Description
                Text("This helps us personalize your experience.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                
                // Option cards
                VStack(spacing: 16) {
                    // First option: Working on reversal
                    JourneyOptionCard(
                        icon: "heart.fill",
                        title: "I'm working on reversing my type 2 diabetes",
                        description: "Let's see if you're a great candidate for reversal through lifestyle changes",
                        isSelected: selectedOption == .workingOnReversal
                    ) {
                        selectedOption = .workingOnReversal
                    }
                    
                    // Second option: Successfully reversed
                    JourneyOptionCard(
                        icon: "trophy.fill",
                        title: "I've successfully reversed my type 2 diabetes",
                        description: "Maintain your remission and inspire others by sharing your success strategies",
                        isSelected: selectedOption == .successfullyReversed
                    ) {
                        selectedOption = .successfullyReversed
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Continue button
                Button(action: {
                    if let selected = selectedOption {
                        appState.selectedJourneyType = selected
                        appState.moveToNextStep()
                    }
                }) {
                    Text("CONTINUE")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.4, green: 0.7, blue: 1.0), // Light blue
                                    Color(red: 0.7, green: 0.5, blue: 1.0)  // Light purple
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
                .disabled(selectedOption == nil)
                .opacity(selectedOption == nil ? 0.5 : 1.0)
            }
        }
    }
}

struct JourneyOptionCard: View {
    let icon: String
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                // Icon circle
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.8)) // Dark blue
                }
                
                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.95, green: 0.98, blue: 0.95)) // Very light green
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color(red: 0.2, green: 0.7, blue: 0.4) : Color(red: 0.9, green: 0.95, blue: 0.9),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

