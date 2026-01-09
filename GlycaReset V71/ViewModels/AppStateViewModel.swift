//
//  AppStateViewModel.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import Foundation
import SwiftUI
import Combine

class AppStateViewModel: ObservableObject {
    @Published var isEligible: Bool = false
    @Published var hasCompletedOnboarding: Bool = false
    @Published var isSignedIn: Bool = false
    @Published var showSignUp: Bool = false
    @Published var currentOnboardingStep: Int = 0
    @Published var selectedJourneyType: JourneyType?
    @Published var medicationStatus: MedicationStatus?
    @Published var hba1cValue: Double?
    @Published var diagnosisYear: Int?
    @Published var weightLossCommitment: WeightLossCommitment?
    @Published var insulinDependency: InsulinDependency?
    @Published var a1cStatus: A1CStatus?
    @Published var advancedComplications: AdvancedComplications?
    @Published var shouldShowCelebration: Bool = false
    @Published var shouldShowLetsGetYouThere: Bool = false
    @Published var shouldShowGreatCandidate: Bool = false
    @Published var shouldShowWeAreHereToHelp: Bool = false
    @Published var usernameError: String?
    @Published var emailError: String?
    
    private let accountManager = LocalAccountManager.shared
    
    init() {
        // Don't automatically restore sign-in state
        // User must sign in explicitly each time they open the app
        isSignedIn = false
        hasCompletedOnboarding = false
        isEligible = false
    }
    
    var totalSteps: Int {
        // If successfully reversed, show 6 steps, otherwise different flow
        if selectedJourneyType == .successfullyReversed {
            return 6
        }
        return 8
    }
    
    // Check if user is signed in
    func checkSignInStatus() {
        if let _ = accountManager.getCurrentUser() {
            isSignedIn = true
            hasCompletedOnboarding = true
            isEligible = true
        } else {
            isSignedIn = false
        }
    }
    
    // Sign in with username/email and password
    func signIn(usernameOrEmail: String, password: String) -> Bool {
        if accountManager.signIn(usernameOrEmail: usernameOrEmail, password: password) != nil {
            isSignedIn = true
            hasCompletedOnboarding = true
            isEligible = true
            return true
        }
        return false
    }
    
    // Sign in with biometric authentication (Face ID/Touch ID)
    func signInWithBiometric(completion: @escaping (Bool, String?) -> Void) {
        // First check if there's a saved account
        guard let account = accountManager.getCurrentUser() ?? accountManager.getAllAccounts().first else {
            completion(false, "No account found. Please sign up first.")
            return
        }
        
        // Authenticate with biometrics
        let biometricManager = BiometricAuthManager.shared
        biometricManager.authenticate(reason: "Sign in to \(account.username)") { success, error in
            if success {
                // Save as current user and sign in
                if let currentUserData = try? JSONEncoder().encode(account) {
                    UserDefaults.standard.set(currentUserData, forKey: "current_user")
                }
                self.isSignedIn = true
                self.hasCompletedOnboarding = true
                self.isEligible = true
                completion(true, nil)
            } else {
                let errorMessage = error?.localizedDescription ?? "Biometric authentication failed"
                completion(false, errorMessage)
            }
        }
    }
    
    // Sign out
    func signOut() {
        accountManager.clearCurrentUser()
        isSignedIn = false
        hasCompletedOnboarding = false
        isEligible = false
        // Reset onboarding state
        currentOnboardingStep = 0
        selectedJourneyType = nil
        medicationStatus = nil
        hba1cValue = nil
        diagnosisYear = nil
        weightLossCommitment = nil
        insulinDependency = nil
        a1cStatus = nil
        advancedComplications = nil
        shouldShowCelebration = false
        shouldShowLetsGetYouThere = false
        shouldShowGreatCandidate = false
        shouldShowWeAreHereToHelp = false
        showSignUp = false
    }
    
    // Check if any accounts exist (to show sign-in vs onboarding)
    func hasAnyAccounts() -> Bool {
        return accountManager.hasAnyAccounts()
    }
    
    // Example logic for eligibility (replace with your real rules)
    func checkEligibility() {
        // Placeholder: update eligibility based on app data
        isEligible = hasCompletedOnboarding
    }
    
    func moveToNextStep() {
        let maxSteps = totalSteps
        if currentOnboardingStep < maxSteps {
            currentOnboardingStep += 1
        }
        // Don't complete onboarding here - let HealthKitConnectionView handle completion
        // The HealthKit screen is the last step, so onboarding completes there
    }
    
    func moveToPreviousStep() {
        if currentOnboardingStep > 0 {
            currentOnboardingStep -= 1
            // Reset flags when going back
            if currentOnboardingStep < 4 {
                shouldShowCelebration = false
                shouldShowLetsGetYouThere = false
            }
            if currentOnboardingStep < 6 {
                shouldShowGreatCandidate = false
                shouldShowWeAreHereToHelp = false
            }
        }
    }
    
    func validateAndProceedWithHbA1c(_ value: Double) {
        hba1cValue = value
        
        // Check if user selected "successfully reversed" but doesn't meet criteria
        if selectedJourneyType == .successfullyReversed {
            let isOnMedication = medicationStatus == .onMedication
            let hba1cTooHigh = value >= 6.5
            
            // If on medication OR HbA1c >= 6.5%, show "Let's Get You There" screen
            if isOnMedication || hba1cTooHigh {
                shouldShowLetsGetYouThere = true
                shouldShowCelebration = false
                currentOnboardingStep = 4 // Jump to "Let's Get You There" screen
                return
            }
        }
        
        // If HbA1c is less than 6.5% and not on medication, show celebration screen
        if value < 6.5 {
            shouldShowCelebration = true
            shouldShowLetsGetYouThere = false
            currentOnboardingStep = 4 // Jump to celebration screen
        } else {
            // Continue to next step normally
            moveToNextStep()
        }
    }
    
    // Check if should show "Let's Get You There" screen based on current state
    func shouldShowLetsGetYouThereScreen() -> Bool {
        guard selectedJourneyType == .successfullyReversed else { return false }
        let isOnMedication = medicationStatus == .onMedication
        if let hba1c = hba1cValue {
            return isOnMedication || hba1c >= 6.5
        }
        return isOnMedication
    }
    
    // Check if user is a good candidate for reversal
    func checkIfGoodCandidate() {
        guard selectedJourneyType == .workingOnReversal else { return }
        
        // Count positive factors
        var positiveFactors = 0
        
        // Early diagnosis (within 6 years)
        if let year = diagnosisYear {
            let currentYear = Calendar.current.component(.year, from: Date())
            if currentYear - year <= 6 {
                positiveFactors += 1
            }
        }
        
        // Weight loss commitment
        if weightLossCommitment == .committed {
            positiveFactors += 1
        }
        
        // No insulin dependency
        if insulinDependency == .notDependent {
            positiveFactors += 1
        }
        
        // A1C below threshold
        if a1cStatus == .belowThreshold {
            positiveFactors += 1
        }
        
        // No advanced complications
        if advancedComplications == .noComplications {
            positiveFactors += 1
        }
        
        // If user has 3 or more positive factors, they're a good candidate
        // Otherwise, show the "We're Here to Help" screen
        shouldShowGreatCandidate = positiveFactors >= 3
        shouldShowWeAreHereToHelp = positiveFactors < 3
    }
    
    // Get years since diagnosis
    func yearsSinceDiagnosis() -> Int? {
        guard let year = diagnosisYear else { return nil }
        let currentYear = Calendar.current.component(.year, from: Date())
        return currentYear - year
    }
    
    // Validate username uniqueness
    func validateUsername(_ username: String) -> Bool {
        usernameError = nil
        if username.isEmpty {
            usernameError = "Username is required"
            return false
        }
        if username.count < 3 {
            usernameError = "Username must be at least 3 characters"
            return false
        }
        if !accountManager.isUsernameUnique(username) {
            usernameError = "Username already taken"
            return false
        }
        return true
    }
    
    // Validate email
    func validateEmail(_ email: String) -> Bool {
        emailError = nil
        if email.isEmpty {
            emailError = "Email is required"
            return false
        }
        // Basic email validation
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        if !emailPredicate.evaluate(with: email) {
            emailError = "Please enter a valid email address"
            return false
        }
        if !accountManager.isEmailUnique(email) {
            emailError = "Email already registered"
            return false
        }
        return true
    }
    
    // Create account
    func createAccount(email: String, username: String, password: String) -> Bool {
        // Validate all fields
        guard validateEmail(email), validateUsername(username) else {
            return false
        }
        
        if password.isEmpty {
            return false
        }
        
        if password.count < 6 {
            return false
        }
        
        // Create account object
        let journeyTypeString = selectedJourneyType == .successfullyReversed ? "successfullyReversed" : "workingOnReversal"
        let medicationStatusString = medicationStatus == .noMedication ? "noMedication" : (medicationStatus == .onMedication ? "onMedication" : nil)
        let weightLossCommitmentString = weightLossCommitment == .committed ? "committed" : (weightLossCommitment == .notCommitted ? "notCommitted" : nil)
        let insulinDependencyString = insulinDependency == .notDependent ? "notDependent" : (insulinDependency == .dependent ? "dependent" : nil)
        let a1cStatusString = a1cStatus == .belowThreshold ? "belowThreshold" : (a1cStatus == .aboveThreshold ? "aboveThreshold" : nil)
        let advancedComplicationsString = advancedComplications == .noComplications ? "noComplications" : (advancedComplications == .hasComplications ? "hasComplications" : nil)
        
        let account = UserAccount(
            email: email,
            username: username,
            password: password, // In production, hash this
            journeyType: journeyTypeString,
            medicationStatus: medicationStatusString,
            hba1cValue: hba1cValue,
            diagnosisYear: diagnosisYear,
            weightLossCommitment: weightLossCommitmentString,
            insulinDependency: insulinDependencyString,
            a1cStatus: a1cStatusString,
            advancedComplications: advancedComplicationsString,
            createdAt: Date()
        )
        
        // Save account locally
        if accountManager.saveAccount(account) {
            // Save as current user for this session (will be used after onboarding completes)
            if let currentUserData = try? JSONEncoder().encode(account) {
                UserDefaults.standard.set(currentUserData, forKey: "current_user")
            }
            return true
        }
        return false
    }
}
