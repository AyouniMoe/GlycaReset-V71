//
//  HealthStatusCheckView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct HealthStatusCheckView: View {
    @ObservedObject var appState: AppStateViewModel
    @State private var selectedA1C: A1CStatus?
    @State private var selectedComplications: AdvancedComplications?
    
    var isFormComplete: Bool {
        selectedA1C != nil && selectedComplications != nil
    }
    
    var body: some View {
        ZStack {
            // Light blue-grey background
            Color(red: 0.95, green: 0.96, blue: 0.98)
                .ignoresSafeArea()
            
            ScrollView {
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
                                
                                // Progress fill (5/8 = approximately 2/3)
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
                                    .frame(width: geometry.size.width * 5 / 8, height: 4)
                            }
                        }
                        .frame(height: 4)
                        .padding(.horizontal, 30)
                        
                        // Step indicator
                        HStack {
                            Text("Step 5 of 8")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(.horizontal, 30)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                    
                    // Orange heart icon in white circle
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .stroke(Color(red: 1.0, green: 0.6, blue: 0.2), lineWidth: 2) // Orange outline
                            )
                        
                        Image(systemName: "heart.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2)) // Orange
                    }
                    .padding(.bottom, 30)
                    
                    // Main title
                    Text("Health status check")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 12)
                    
                    // Subtitle
                    Text("Just a couple more questions about your current health.")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 30)
                    
                    // Question 1: A1C Status
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Is your A1C below 8.5-9%?")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 30)
                        
                        VStack(spacing: 12) {
                            HealthOptionCard(
                                text: "Yes, my A1C is below 8.5-9%",
                                isSelected: selectedA1C == .belowThreshold
                            ) {
                                selectedA1C = .belowThreshold
                            }
                            
                            HealthOptionCard(
                                text: "No, my A1C is above 8.5-9%",
                                isSelected: selectedA1C == .aboveThreshold
                            ) {
                                selectedA1C = .aboveThreshold
                            }
                        }
                        .padding(.horizontal, 30)
                    }
                    .padding(.bottom, 30)
                    
                    // Question 2: Advanced Complications
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Do you have advanced diabetes complications?")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("(e.g., severe neuropathy, retinopathy, kidney disease)")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 30)
                        
                        VStack(spacing: 12) {
                            HealthOptionCard(
                                text: "No, I don't have advanced complications",
                                isSelected: selectedComplications == .noComplications
                            ) {
                                selectedComplications = .noComplications
                            }
                            
                            HealthOptionCard(
                                text: "Yes, I have advanced complications",
                                isSelected: selectedComplications == .hasComplications
                            ) {
                                selectedComplications = .hasComplications
                            }
                        }
                        .padding(.horizontal, 30)
                    }
                    .padding(.bottom, 30)
                    
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
                                        .stroke(Color.black.opacity(0.2), lineWidth: 1)
                                )
                                .cornerRadius(16)
                        }
                        
                        // Continue button
                        Button(action: {
                            if let a1c = selectedA1C, let complications = selectedComplications {
                                appState.a1cStatus = a1c
                                appState.advancedComplications = complications
                                appState.checkIfGoodCandidate()
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
                                            Color(red: 0.7, green: 0.4, blue: 0.9), // Purple
                                            Color(red: 1.0, green: 0.5, blue: 0.7)  // Pink
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                        }
                        .disabled(!isFormComplete)
                        .opacity(isFormComplete ? 1.0 : 0.5)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                }
            }
        }
    }
}

struct HealthOptionCard: View {
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
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                Color(red: 0.8, green: 0.95, blue: 0.8), // Light green glow
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

