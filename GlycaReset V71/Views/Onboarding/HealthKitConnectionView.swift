//
//  HealthKitConnectionView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI
import HealthKit

struct HealthKitConnectionView: View {
    @ObservedObject var appState: AppStateViewModel
    private let healthKitManager = HealthKitManager.shared
    @State private var isConnecting = false
    @State private var connectionError: String?
    
    var currentStep: Int {
        appState.selectedJourneyType == .successfullyReversed ? 6 : 8
    }
    
    var body: some View {
        ZStack {
            // Light blue-green background
            Color(red: 0.92, green: 0.96, blue: 0.98)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.9, green: 0.8, blue: 1.0)) // Light purple
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 30)
                    
                    // Title
                    Text("Connect Your Health Data")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 12)
                    
                    // Subtitle
                    Text("Sync your wearable data through HealthKit for automatic tracking and personalized insights.")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 30)
                    
                    // Data sync details box
                    VStack(alignment: .leading, spacing: 16) {
                        Text("We'll sync:")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HealthDataBulletPoint(text: "Blood glucose levels")
                            HealthDataBulletPoint(text: "Steps and physical activity")
                            HealthDataBulletPoint(text: "Weight and body measurements")
                            HealthDataBulletPoint(text: "Heart rate and sleep data")
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.95, green: 0.95, blue: 0.95)) // Light gray
                    )
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                    
                    // Privacy notice
                    HStack(alignment: .top, spacing: 8) {
                        Text("Privacy:")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("Your health data is encrypted and never shared with third parties. You can revoke access anytime in Settings.")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.95, green: 0.98, blue: 0.9)) // Light yellow-green
                    )
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                    
                    // Error message
                    if let error = connectionError {
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding(.horizontal, 30)
                            .padding(.bottom, 20)
                    }
                    
                    // Action buttons
                    VStack(spacing: 16) {
                        // CONNECT HEALTHKIT button
                        Button(action: {
                            connectHealthKit()
                        }) {
                            Text("CONNECT HEALTHKIT")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.2, green: 0.6, blue: 1.0), // Blue
                                            Color(red: 0.7, green: 0.4, blue: 0.9)  // Purple
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                        }
                        .disabled(isConnecting)
                        .opacity(isConnecting ? 0.6 : 1.0)
                        
                        // SKIP FOR NOW button
                        Button(action: {
                            skipHealthKit()
                        }) {
                            Text("SKIP FOR NOW")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .cornerRadius(16)
                        }
                        .disabled(isConnecting)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                }
            }
        }
    }
    
    private func connectHealthKit() {
        guard healthKitManager.isHealthKitAvailable() else {
            connectionError = "HealthKit is not available on this device"
            return
        }
        
        isConnecting = true
        connectionError = nil
        
        healthKitManager.requestAuthorization { success, error in
            DispatchQueue.main.async {
                isConnecting = false
                
                if success {
                    // Start syncing data
                    syncHealthData()
                    // Complete onboarding and auto-sign in the user
                    appState.hasCompletedOnboarding = true
                    // Auto-sign in the user who just created their account
                    if let currentUser = LocalAccountManager.shared.getCurrentUser() {
                        // User account exists, sign them in automatically
                        appState.isSignedIn = true
                    } else {
                        // If no current user, try to get the most recently created account
                        let accounts = LocalAccountManager.shared.getAllAccounts()
                        if let latestAccount = accounts.sorted(by: { $0.createdAt > $1.createdAt }).first {
                            // Sign in with the most recently created account
                            if LocalAccountManager.shared.signIn(usernameOrEmail: latestAccount.username, password: latestAccount.password) != nil {
                                appState.isSignedIn = true
                            }
                        }
                    }
                    appState.checkEligibility()
                } else {
                    connectionError = error?.localizedDescription ?? "Failed to connect to HealthKit"
                }
            }
        }
    }
    
    private func skipHealthKit() {
        // Complete onboarding without HealthKit and auto-sign in the user
        appState.hasCompletedOnboarding = true
        // Auto-sign in the user who just created their account
        if let currentUser = LocalAccountManager.shared.getCurrentUser() {
            // User account exists, sign them in automatically
            appState.isSignedIn = true
        } else {
            // If no current user, try to get the most recently created account
            let accounts = LocalAccountManager.shared.getAllAccounts()
            if let latestAccount = accounts.sorted(by: { $0.createdAt > $1.createdAt }).first {
                // Sign in with the most recently created account
                if LocalAccountManager.shared.signIn(usernameOrEmail: latestAccount.username, password: latestAccount.password) != nil {
                    appState.isSignedIn = true
                }
            }
        }
        appState.checkEligibility()
    }
    
    private func syncHealthData() {
        // Sync blood glucose
        healthKitManager.readBloodGlucose { values, error in
            if let values = values {
                // Store or process blood glucose data
                print("Synced \(values.count) blood glucose readings")
            }
        }
        
        // Sync step count
        healthKitManager.readStepCount { steps, error in
            if let steps = steps {
                // Store or process step count
                print("Synced step count: \(steps)")
            }
        }
        
        // Sync weight
        healthKitManager.readWeight { weight, error in
            if let weight = weight {
                // Store or process weight
                print("Synced weight: \(weight) kg")
            }
        }
        
        // Sync heart rate
        healthKitManager.readHeartRate { heartRate, error in
            if let heartRate = heartRate {
                // Store or process heart rate
                print("Synced heart rate: \(heartRate) bpm")
            }
        }
        
        // Sync sleep data
        healthKitManager.readSleepData { sleepHours, error in
            if let sleepHours = sleepHours {
                // Store or process sleep data
                print("Synced sleep: \(sleepHours) hours")
            }
        }
    }
}

struct HealthDataBulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
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

