//
//  GreatCandidateView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct GreatCandidateView: View {
    @ObservedObject var appState: AppStateViewModel
    
    var candidateReasons: [CandidateReason] {
        var reasons: [CandidateReason] = []
        
        // Early diagnosis
        if let years = appState.yearsSinceDiagnosis(), years <= 6 {
            reasons.append(CandidateReason(
                title: "Early diagnosis",
                description: "You were diagnosed \(years) year\(years == 1 ? "" : "s") ago. Research shows reversal is most effective within the first 6 years."
            ))
        }
        
        // Weight loss commitment
        if appState.weightLossCommitment == .committed {
            reasons.append(CandidateReason(
                title: "Weight loss commitment",
                description: "You're ready to lose 10-15% of body weight, a proven key factor in reversal."
            ))
        }
        
        // No insulin dependency
        if appState.insulinDependency == .notDependent {
            reasons.append(CandidateReason(
                title: "No insulin dependency",
                description: "Not being on long-term insulin means your pancreas can still produce insulin effectively."
            ))
        }
        
        // Controlled A1C
        if appState.a1cStatus == .belowThreshold {
            reasons.append(CandidateReason(
                title: "Controlled A1C",
                description: "Your A1C below 8.5-9% indicates your diabetes is manageable and responsive to interventions."
            ))
        }
        
        // No advanced complications
        if appState.advancedComplications == .noComplications {
            reasons.append(CandidateReason(
                title: "No advanced complications",
                description: "Your body hasn't experienced severe organ damage, making recovery more achievable."
            ))
        }
        
        return reasons
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
                    
                    // Medal/ribbon icon in green circle
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.2, green: 0.7, blue: 0.4)) // Green
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "medal.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 20)
                    
                    // Main heading
                    Text("You're a Great Candidate!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 12)
                    
                    // Subheading
                    Text("Based on your profile, you have excellent potential for reversing type 2 diabetes through lifestyle changes.")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 30)
                    
                    // Why You're a Great Candidate box
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Why You're a Great Candidate:")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(candidateReasons, id: \.title) { reason in
                                CandidateBulletPoint(reason: reason)
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.9, green: 0.98, blue: 0.9)) // Light green
                    )
                    .padding(.horizontal, 30)
                    .padding(.bottom, 16)
                    
                    // Your Journey Starts With box
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Journey Starts With:")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            JourneyBulletPoint(text: "Daily tracking and progress monitoring")
                            JourneyBulletPoint(text: "Evidence-based learning modules")
                            JourneyBulletPoint(text: "Gamified rewards and achievements")
                            JourneyBulletPoint(text: "Learn from success stories in the community")
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
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
                            .fill(Color(red: 1.0, green: 0.95, blue: 0.95)) // Light pink/beige
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
                                    Color(red: 0.7, green: 0.4, blue: 0.9) // Purple
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

struct CandidateReason {
    let title: String
    let description: String
}

struct CandidateBulletPoint: View {
    let reason: CandidateReason
    
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
            
            VStack(alignment: .leading, spacing: 4) {
                Text(reason.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                
                Text(reason.description)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
            }
        }
    }
}

struct JourneyBulletPoint: View {
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

