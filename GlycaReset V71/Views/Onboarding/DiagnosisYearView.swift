//
//  DiagnosisYearView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct DiagnosisYearView: View {
    @ObservedObject var appState: AppStateViewModel
    @State private var yearText: String = ""
    @FocusState private var isInputFocused: Bool
    
    init(appState: AppStateViewModel) {
        self.appState = appState
        // Restore previous value if available
        if let year = appState.diagnosisYear {
            _yearText = State(initialValue: String(year))
        }
    }
    
    var isValidInput: Bool {
        if let year = Int(yearText) {
            let currentYear = Calendar.current.component(.year, from: Date())
            return year >= 1900 && year <= currentYear
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
                            
                            // Progress fill (2/8 = 1/4)
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
                                .frame(width: geometry.size.width * 2 / 8, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 30)
                    
                    // Step indicator
                    HStack {
                        Text("Step 2 of 8")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                Spacer()
                
                // Heart icon in light blue circle
                ZStack {
                    Circle()
                        .fill(Color(red: 0.8, green: 0.9, blue: 1.0)) // Light blue
                        .frame(width: 80, height: 80)
                        .overlay(
                            Circle()
                                .stroke(Color(red: 0.2, green: 0.3, blue: 0.8), lineWidth: 2) // Dark blue outline
                        )
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.8)) // Dark blue
                }
                .padding(.bottom, 30)
                
                // Main title
                Text("When were you first diagnosed?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 12)
                
                // Context text
                Text("Research shows the best outcomes occur when diabetes is caught early.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                
                // Input field section
                VStack(alignment: .leading, spacing: 8) {
                    // Label
                    Text("Year of Type 2 Diabetes Diagnosis")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 30)
                    
                    // Input field
                    TextField("e.g., 2021", text: $yearText)
                        .keyboardType(.numberPad)
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
                    
                    // Helper text with dynamic message
                    if let year = Int(yearText), year >= 1900 {
                        let currentYear = Calendar.current.component(.year, from: Date())
                        let yearsSinceDiagnosis = currentYear - year
                        if yearsSinceDiagnosis <= 6 && yearsSinceDiagnosis >= 0 {
                            Text("Great news! Being diagnosed within the past 6 years means you have a higher likelihood of successfully reversing type 2 diabetes.")
                                .font(.system(size: 14))
                                .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.4))
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, 30)
                        } else {
                            Text("Early diagnosis (within 6 years) is ideal for reversal")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 30)
                        }
                    } else {
                        Text("Early diagnosis (within 6 years) is ideal for reversal")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 30)
                    }
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
                        if let year = Int(yearText) {
                            appState.diagnosisYear = year
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
                                        Color(red: 0.4, green: 0.7, blue: 1.0)  // Blue
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
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

