//
//  WeightLossCommitmentView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct WeightLossCommitmentView: View {
    @ObservedObject var appState: AppStateViewModel
    @State private var selectedOption: WeightLossCommitment?
    
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
                            
                            // Progress fill (3/8 = approximately 1/3)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.7, green: 0.4, blue: 0.9), // Purple
                                            Color(red: 1.0, green: 0.7, blue: 0.3)  // Orange/Yellow
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * 3 / 8, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 30)
                    
                    // Step indicator
                    HStack {
                        Text("Step 3 of 8")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                Spacer()
                
                // Icon with light purple background
                ZStack {
                    Circle()
                        .fill(Color(red: 0.9, green: 0.8, blue: 1.0)) // Light purple
                        .frame(width: 80, height: 80)
                    
                    // Chart/line icon representing weight loss
                    Image(systemName: "chart.line.downtrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.8)) // Darker purple
                }
                .padding(.bottom, 30)
                
                // Main question
                Text("Are you committed to weight loss?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 12)
                
                // Descriptive text
                Text("Losing 10-15% of your body weight is a key factor in diabetes reversal.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                
                // Option cards
                VStack(spacing: 16) {
                    // First option: Committed
                    WeightLossOptionCard(
                        text: "Yes, I'm ready to work on losing 10-15% of my body weight",
                        isSelected: selectedOption == .committed
                    ) {
                        selectedOption = .committed
                    }
                    
                    // Second option: Not committed
                    WeightLossOptionCard(
                        text: "No, I'm not able to commit to this right now",
                        isSelected: selectedOption == .notCommitted
                    ) {
                        selectedOption = .notCommitted
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Bottom navigation buttons
                HStack(spacing: 16) {
                    // Back button
                    Button(action: {
                        appState.moveToPreviousStep()
                    }) {
                        Text("BACK")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(red: 0.8, green: 0.95, blue: 0.8), lineWidth: 1) // Light green border
                            )
                            .cornerRadius(16)
                    }
                    
                    // Continue button
                    Button(action: {
                        if let selected = selectedOption {
                            appState.weightLossCommitment = selected
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
                    .disabled(selectedOption == nil)
                    .opacity(selectedOption == nil ? 0.5 : 1.0)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
    }
}

struct WeightLossOptionCard: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Radio button indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color(red: 0.2, green: 0.7, blue: 0.4) : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color(red: 0.2, green: 0.7, blue: 0.4))
                            .frame(width: 12, height: 12)
                    }
                }
                
                // Text
                Text(text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(red: 0.95, green: 0.98, blue: 0.95) : Color.white) // Light green if selected, white if not
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color(red: 0.8, green: 0.95, blue: 0.8) : Color.gray.opacity(0.3),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

