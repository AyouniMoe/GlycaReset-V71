//
//  InsulinDependencyView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct InsulinDependencyView: View {
    @ObservedObject var appState: AppStateViewModel
    @State private var selectedOption: InsulinDependency?
    
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
                            
                            // Progress fill (4/8 = 1/2)
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
                                .frame(width: geometry.size.width * 4 / 8, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 30)
                    
                    // Step indicator
                    HStack {
                        Text("Step 4 of 8")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                Spacer()
                
                // Heart icon in vibrant green circle
                ZStack {
                    Circle()
                        .fill(Color(red: 0.9, green: 0.98, blue: 0.9)) // Light green
                        .frame(width: 80, height: 80)
                        .overlay(
                            Circle()
                                .stroke(Color(red: 0.2, green: 0.7, blue: 0.4), lineWidth: 2) // Vibrant green border
                        )
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.4)) // Vibrant green
                }
                .padding(.bottom, 30)
                
                // Main title
                Text("Insulin dependency")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 12)
                
                // Descriptive text
                Text("Long-term insulin dependency can make reversal more challenging.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                
                // Option cards
                VStack(spacing: 16) {
                    // First option: Not dependent
                    InsulinOptionCard(
                        text: "No, I'm not dependent on long-term insulin",
                        isSelected: selectedOption == .notDependent
                    ) {
                        selectedOption = .notDependent
                    }
                    
                    // Second option: Dependent
                    InsulinOptionCard(
                        text: "Yes, I'm dependent on long-term insulin therapy",
                        isSelected: selectedOption == .dependent
                    ) {
                        selectedOption = .dependent
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
                                    .stroke(Color(red: 0.2, green: 0.7, blue: 0.4), lineWidth: 1) // Bright green outline
                            )
                            .cornerRadius(16)
                    }
                    
                    // Continue button
                    Button(action: {
                        if let selected = selectedOption {
                            appState.insulinDependency = selected
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
                                        Color(red: 1.0, green: 0.5, blue: 0.7)  // Pink/purple
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

struct InsulinOptionCard: View {
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

