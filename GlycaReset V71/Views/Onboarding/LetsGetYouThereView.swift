//
//  LetsGetYouThereView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct LetsGetYouThereView: View {
    @ObservedObject var appState: AppStateViewModel
    
    var hba1cDisplay: String {
        if let value = appState.hba1cValue {
            return String(format: "%.1f", value)
        }
        return "6.5"
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
                                
                                // Progress fill (4/6 = 2/3)
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
                                    .frame(width: geometry.size.width * 4 / 6, height: 4)
                            }
                        }
                        .frame(height: 4)
                        .padding(.horizontal, 30)
                        
                        // Step indicator
                        HStack {
                            Text("Step 4 of 6")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(.horizontal, 30)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                    
                    // Orange heart icon
                    ZStack {
                        Circle()
                            .fill(Color(red: 1.0, green: 0.6, blue: 0.2)) // Orange
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "heart.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 20)
                    
                    // Title
                    Text("Let's Get You There")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 16)
                    
                    // Description
                    Text("Based on your current health metrics, it appears you haven't achieved full remission yet, or you may have fallen out of remission. But don't worry—this app can help you get back on track.")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 30)
                    
                    // Why Remission Criteria Aren't Met box
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Why Remission Criteria Aren't Met:")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            // Show HbA1c reason if applicable
                            if let hba1c = appState.hba1cValue, hba1c >= 6.5 {
                                HStack(alignment: .top, spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(red: 1.0, green: 0.6, blue: 0.2)) // Orange
                                            .frame(width: 24, height: 24)
                                        
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("HbA1c in diabetes range")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.black)
                                        
                                        Text("Your current HbA1c of \(hba1cDisplay)% is at or above 6.5%, which indicates diabetes. True remission requires maintaining HbA1c below 6.5% without diabetes medication for at least 3 months.")
                                            .font(.system(size: 14))
                                            .foregroundColor(.black)
                                    }
                                }
                            }
                            
                            // Show medication reason if applicable
                            if appState.medicationStatus == .onMedication {
                                HStack(alignment: .top, spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(red: 1.0, green: 0.6, blue: 0.2)) // Orange
                                            .frame(width: 24, height: 24)
                                        
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Currently on diabetes medication")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.black)
                                        
                                        Text("True remission requires maintaining HbA1c below 6.5% without diabetes medication for at least 3 months.")
                                            .font(.system(size: 14))
                                            .foregroundColor(.black)
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.98, green: 0.96, blue: 0.92)) // Light beige
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 0.8, green: 0.95, blue: 0.8), lineWidth: 1) // Light green border
                            )
                    )
                    .padding(.horizontal, 30)
                    .padding(.bottom, 16)
                    
                    // This App Will Help You box
                    VStack(alignment: .leading, spacing: 12) {
                        Text("This App Will Help You:")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            LetsGetYouThereHelpBulletPoint(text: "Achieve actual diabetes reversal and remission")
                            LetsGetYouThereHelpBulletPoint(text: "Track your HbA1c and other key metrics")
                            LetsGetYouThereHelpBulletPoint(text: "Learn proven lifestyle changes for reversal")
                            LetsGetYouThereHelpBulletPoint(text: "Build sustainable habits with simplified steps")
                            LetsGetYouThereHelpBulletPoint(text: "Connect with others who've successfully reversed")
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.9, green: 0.85, blue: 0.95)) // Light blue/purple
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 0.8, green: 0.95, blue: 0.8), lineWidth: 1) // Light green border
                            )
                    )
                    .padding(.horizontal, 30)
                    .padding(.bottom, 16)
                    
                    // Disclaimers box
                    VStack(alignment: .leading, spacing: 16) {
                        // Medical Disclaimer
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Medical Disclaimer:")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("Always consult with your healthcare provider before making any changes to your diabetes management plan. GlycaReset is provided solely as a behavioral habit-building tool and community insight-sharing platform. GlycaReset and its operators assume no legal responsibility for any adverse health outcomes, complications, or changes in medical condition that may occur from lifestyle or dietary modifications undertaken through use of this application. All health decisions and their consequences remain the full responsibility of the user. This app does not provide medical advice, diagnosis, or treatment.")
                                .font(.system(size: 10))
                                .foregroundColor(.black)
                        }
                        
                        // Data Privacy
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Data Privacy:")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("All health and fitness data generated within this application is stored locally on your device and is not owned, accessed, or controlled by GlycaReset. The only user information collected by GlycaReset includes: username, email address, login credentials, and user type (active reversal or maintaining remission). We do not collect, store, or have access to your personal health metrics or medical information.")
                                .font(.system(size: 10))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.98, green: 0.96, blue: 0.92)) // Light beige
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 0.8, green: 0.95, blue: 0.8), lineWidth: 1) // Light green border
                            )
                    )
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                    
                    // Bottom navigation buttons
                    HStack(spacing: 16) {
                        // Back button
                        Button(action: {
                            appState.moveToPreviousStep()
                        }) {
                            Text("BACK")
                                .font(.system(size: 16, weight: .bold))
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
                            appState.moveToNextStep()
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
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                }
            }
        }
    }
}

struct LetsGetYouThereHelpBulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.2, green: 0.4, blue: 0.8)) // Blue
                    .frame(width: 24, height: 24)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.black)
        }
    }
}

