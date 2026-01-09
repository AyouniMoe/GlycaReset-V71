//
//  WeAreHereToHelpView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct WeAreHereToHelpView: View {
    @ObservedObject var appState: AppStateViewModel
    
    var challengingFactors: [ChallengingFactor] {
        var factors: [ChallengingFactor] = []
        
        // Weight loss readiness
        if appState.weightLossCommitment == .notCommitted {
            factors.append(ChallengingFactor(
                title: "Weight loss readiness",
                description: "Significant weight loss (10-15% of body weight) is crucial for reversal. When you're ready, we can help with simplified habit building."
            ))
        }
        
        // Insulin dependency
        if appState.insulinDependency == .dependent {
            factors.append(ChallengingFactor(
                title: "Insulin dependency",
                description: "Long-term insulin use indicates reduced pancreatic function. Work closely with your doctor on any medication changes."
            ))
        }
        
        // Higher A1C levels
        if appState.a1cStatus == .aboveThreshold {
            factors.append(ChallengingFactor(
                title: "Higher A1C levels",
                description: "An A1C above 8.5-9% suggests your diabetes needs better control before attempting reversal. Focus on stabilization first."
            ))
        }
        
        // Advanced complications
        if appState.advancedComplications == .hasComplications {
            factors.append(ChallengingFactor(
                title: "Advanced complications",
                description: "Existing complications require careful medical supervision. Reversal efforts should prioritize preventing further damage."
            ))
        }
        
        // Late diagnosis (more than 6 years)
        if let years = appState.yearsSinceDiagnosis(), years > 6 {
            factors.append(ChallengingFactor(
                title: "Later diagnosis",
                description: "Being diagnosed more than 6 years ago can make reversal more challenging, but it's still possible with dedication and proper support."
            ))
        }
        
        return factors
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
                                
                                // Progress fill (6/8 = 3/4)
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
                                    .frame(width: geometry.size.width * 6 / 8, height: 4)
                            }
                        }
                        .frame(height: 4)
                        .padding(.horizontal, 30)
                        
                        // Step indicator
                        HStack {
                            Text("Step 6 of 8")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(.horizontal, 30)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                    
                    // Purple heart icon
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.7, green: 0.4, blue: 0.9)) // Purple
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "heart.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 20)
                    
                    // Main heading
                    Text("We're Here to Help")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 12)
                    
                    // Subheading
                    Text("While diabetes reversal may be more challenging in your situation, this app can still help you manage your condition and improve your health.")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 30)
                    
                    // Factors to Consider box
                    if !challengingFactors.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Factors to Consider:")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(challengingFactors, id: \.title) { factor in
                                    ChallengingFactorBulletPoint(factor: factor)
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.98, green: 0.96, blue: 0.92)) // Light beige
                        )
                        .padding(.horizontal, 30)
                        .padding(.bottom, 16)
                    }
                    
                    // This App Will Help You box
                    VStack(alignment: .leading, spacing: 16) {
                        Text("This App Will Help You:")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HelpBulletPoint(text: "Better manage your diabetes")
                            HelpBulletPoint(text: "Track your health metrics")
                            HelpBulletPoint(text: "Learn about healthy lifestyle choices")
                            HelpBulletPoint(text: "Connect with others on a similar journey")
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.9, green: 0.85, blue: 0.95)) // Light blue
                    )
                    .padding(.horizontal, 30)
                    .padding(.bottom, 16)
                    
                    // Disclaimer box
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
                            .fill(Color(red: 1.0, green: 0.95, blue: 0.95)) // Light red/pink
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
                                        .stroke(Color(red: 0.2, green: 0.7, blue: 0.4), lineWidth: 1) // Green outline
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
                                            Color(red: 0.7, green: 0.4, blue: 0.9), // Purple
                                            Color(red: 0.7, green: 0.4, blue: 0.9)  // Purple
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

struct ChallengingFactor {
    let title: String
    let description: String
}

struct ChallengingFactorBulletPoint: View {
    let factor: ChallengingFactor
    
    var body: some View {
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
                Text(factor.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                
                Text(factor.description)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
            }
        }
    }
}

struct HelpBulletPoint: View {
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

