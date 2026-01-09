//
//  MedicationStatusView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct MedicationStatusView: View {
    @ObservedObject var appState: AppStateViewModel
    @State private var selectedOption: MedicationStatus?
    
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
                            
                            // Progress fill (2/6 = 1/3)
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
                                .frame(width: geometry.size.width * 2 / 6, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 30)
                    
                    // Step indicator
                    HStack {
                        Text("Step 2 of 6")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Capsule icon
                ZStack {
                    Circle()
                        .fill(Color(red: 0.9, green: 0.8, blue: 1.0)) // Light purple
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "capsule.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.8)) // Purple
                }
                .padding(.bottom, 30)
                
                // Main title
                Text("Current medication status")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 12)
                
                // Description
                Text("Let us know if you're currently taking any diabetes medication.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                
                // Option cards
                VStack(spacing: 16) {
                    // First option: No medication
                    MedicationOptionCard(
                        title: "No, I'm not on any diabetes medication",
                        isSelected: selectedOption == .noMedication
                    ) {
                        selectedOption = .noMedication
                    }
                    
                    // Second option: On medication
                    MedicationOptionCard(
                        title: "Yes, I'm on diabetes medication",
                        isSelected: selectedOption == .onMedication
                    ) {
                        selectedOption = .onMedication
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
                                    .stroke(Color.black.opacity(0.2), lineWidth: 1)
                                    .shadow(color: Color(red: 0.8, green: 0.95, blue: 0.8), radius: 4)
                            )
                            .cornerRadius(16)
                    }
                    
                    // Continue button
                    Button(action: {
                        if let selected = selectedOption {
                            appState.medicationStatus = selected
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
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(red: 1.0, green: 0.5, blue: 0.7), lineWidth: 1)
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

struct MedicationOptionCard: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Radio button
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
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color(red: 0.8, green: 0.95, blue: 0.8) : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

