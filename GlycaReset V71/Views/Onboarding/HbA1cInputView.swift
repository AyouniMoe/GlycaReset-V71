//
//  HbA1cInputView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct HbA1cInputView: View {
    @ObservedObject var appState: AppStateViewModel
    @State private var hba1cText: String = ""
    @FocusState private var isInputFocused: Bool
    
    init(appState: AppStateViewModel) {
        self.appState = appState
        // Restore previous value if available
        if let value = appState.hba1cValue {
            _hba1cText = State(initialValue: String(format: "%.1f", value))
        }
    }
    
    var isValidInput: Bool {
        if let value = Double(hba1cText), value > 0 && value <= 20 {
            return true
        }
        return false
    }
    
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
                            
                            // Progress fill (3/6 = 1/2)
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
                                .frame(width: geometry.size.width * 3 / 6, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 30)
                    
                    // Step indicator
                    HStack {
                        Text("Step 3 of 6")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Heart icon in light green circle
                ZStack {
                    Circle()
                        .fill(Color(red: 0.9, green: 0.98, blue: 0.9)) // Light green
                        .frame(width: 80, height: 80)
                        .shadow(color: Color(red: 0.8, green: 0.95, blue: 0.8).opacity(0.5), radius: 8)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.4)) // Green
                }
                .padding(.bottom, 30)
                
                // Main title
                Text("What is your current HbA1c?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 12)
                
                // Description
                Text("This helps us track your maintenance progress.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                
                // Input field section
                VStack(alignment: .leading, spacing: 8) {
                    // Label
                    Text("HbA1c Level (%)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 30)
                    
                    // Input field
                    TextField("e.g., 5.5", text: $hba1cText)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(12)
                        .focused($isInputFocused)
                        .padding(.horizontal, 30)
                    
                    // Helper text
                    Text("Enter your HbA1c level as a percentage (e.g., 5.5 for 5.5%)")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 30)
                }
                
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
                        if let value = Double(hba1cText) {
                            appState.validateAndProceedWithHbA1c(value)
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
                    .disabled(!isValidInput)
                    .opacity(isValidInput ? 1.0 : 0.5)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
        .onTapGesture {
            isInputFocused = false
        }
    }
}

