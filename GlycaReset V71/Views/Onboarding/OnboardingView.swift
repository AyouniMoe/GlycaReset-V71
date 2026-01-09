//
//  OnboardingView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var appState: AppStateViewModel
    
    var body: some View {
        if appState.currentOnboardingStep == 0 {
            // Welcome screen
            WelcomeScreenView(appState: appState)
        } else if appState.currentOnboardingStep == 1 {
            // Journey selection screen
            JourneySelectionView(appState: appState)
        } else if appState.currentOnboardingStep == 2 && appState.selectedJourneyType == .workingOnReversal {
            // Diagnosis year screen (for users working on reversal)
            DiagnosisYearView(appState: appState)
        } else if appState.currentOnboardingStep == 3 && appState.selectedJourneyType == .workingOnReversal {
            // Weight loss commitment screen (for users working on reversal)
            WeightLossCommitmentView(appState: appState)
        } else if appState.currentOnboardingStep == 4 && appState.selectedJourneyType == .workingOnReversal {
            // Insulin dependency screen (for users working on reversal)
            InsulinDependencyView(appState: appState)
        } else if appState.currentOnboardingStep == 5 && appState.selectedJourneyType == .workingOnReversal {
            // Health status check screen (for users working on reversal)
            HealthStatusCheckView(appState: appState)
        } else if appState.currentOnboardingStep == 6 && appState.shouldShowGreatCandidate {
            // Great candidate screen (if user meets criteria for higher reversal likelihood)
            GreatCandidateView(appState: appState)
        } else if appState.currentOnboardingStep == 6 && appState.shouldShowWeAreHereToHelp {
            // We're Here to Help screen (if user has lower reversal likelihood)
            WeAreHereToHelpView(appState: appState)
        } else if appState.currentOnboardingStep == 2 && appState.selectedJourneyType == .successfullyReversed {
            // Medication status screen (only for successfully reversed)
            MedicationStatusView(appState: appState)
        } else if appState.currentOnboardingStep == 3 && appState.selectedJourneyType == .successfullyReversed {
            // HbA1c input screen (only for successfully reversed)
            HbA1cInputView(appState: appState)
        } else if appState.currentOnboardingStep == 4 && appState.shouldShowLetsGetYouThere {
            // "Let's Get You There" screen (if on medication OR HbA1c >= 6.5%)
            LetsGetYouThereView(appState: appState)
        } else if appState.currentOnboardingStep == 4 && appState.shouldShowCelebration {
            // Celebration screen (only if HbA1c < 6.5% and not on medication)
            RemissionCelebrationView(appState: appState)
        } else if appState.currentOnboardingStep == 5 && appState.selectedJourneyType == .successfullyReversed {
            // Create account screen (Step 5 of 6 for successfully reversed)
            CreateAccountView(appState: appState)
        } else if appState.currentOnboardingStep == 6 && appState.selectedJourneyType == .successfullyReversed {
            // HealthKit connection screen (Step 6 of 6 for successfully reversed)
            HealthKitConnectionView(appState: appState)
        } else if appState.currentOnboardingStep == 7 && appState.selectedJourneyType == .workingOnReversal {
            // Create account screen (Step 7 of 8 for working on reversal)
            CreateAccountView(appState: appState)
        } else if appState.currentOnboardingStep == 8 && appState.selectedJourneyType == .workingOnReversal {
            // HealthKit connection screen (Step 8 of 8 for working on reversal)
            HealthKitConnectionView(appState: appState)
        } else {
            // More onboarding steps will go here
            // For now, if onboarding is complete, ContentView will show DashboardView
            EmptyView()
        }
    }
}
