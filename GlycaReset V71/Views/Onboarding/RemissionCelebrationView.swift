//
//  RemissionCelebrationView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct RemissionCelebrationView: View {
    @ObservedObject var appState: AppStateViewModel
    
    var body: some View {
        ZStack {
            // Light background
            Color(red: 0.98, green: 0.98, blue: 0.98)
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
                    
                    // Trophy icon
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.2, green: 0.7, blue: 0.4)) // Green
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 20)
                    
                    // Title
                    Text("Fantastic!")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.bottom, 12)
                    
                    // Congratulatory message
                    Text("Congratulations on achieving remission! Let's help you maintain your success and inspire others.")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 30)
                    
                    // Your Impact Starts Here box
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Impact Starts Here:")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            ImpactBulletPoint(text: "Maintain remission with daily tracking")
                            ImpactBulletPoint(text: "Share your success strategies with others")
                            ImpactBulletPoint(text: "Earn points by helping the community")
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.9, green: 0.98, blue: 0.9)) // Light green
                    )
                    .padding(.horizontal, 30)
                    .padding(.bottom, 16)
                    
                    // Inspire Others box
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Inspire Others:")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("Your journey can motivate those just starting. Share the lifestyle and diet changes that worked for you to earn bonus XP!")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 1.0, green: 0.98, blue: 0.8)) // Light yellow
                    )
                    .padding(.horizontal, 30)
                    .padding(.bottom, 16)
                    
                    // Disclaimer and Privacy box
                    VStack(alignment: .leading, spacing: 16) {
                        // Medical Disclaimer
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Medical Disclaimer:")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("Always consult with your healthcare provider before making any changes to your diabetes management plan. GlycaReset is provided solely as a behavioral habit-building tool and community insight-sharing platform. DiaBets and its operators assume no legal responsibility for any adverse health outcomes, complications, or changes in medical condition that may occur from lifestyle or dietary modifications undertaken through use of this application. All health decisions and their consequences remain the full responsibility of the user. This app does not provide medical advice, diagnosis, or treatment.")
                                .font(.system(size: 12))
                                .foregroundColor(.black)
                        }
                        
                        // Data Privacy
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Data Privacy:")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("All health and fitness data generated within this application is stored locally on your device and is not owned, accessed, or controlled by GlycaReset. The only user information collected by GlycaReset includes: username, email address, login credentials, and user type (active reversal or maintaining remission). We do not collect, store, or have access to your personal health metrics or medical information.")
                                .font(.system(size: 12))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 1.0, green: 0.95, blue: 0.95)) // Light pink/red
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

struct ImpactBulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.2, green: 0.7, blue: 0.4)) // Green
                    .frame(width: 24, height: 24)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.black)
        }
    }
}

