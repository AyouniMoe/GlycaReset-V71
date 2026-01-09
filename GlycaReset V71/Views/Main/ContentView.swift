//
//  ContentView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppStateViewModel()

    var body: some View {
        if appState.isSignedIn && appState.isEligible {
            // User is signed in and has completed onboarding
            DashboardView()
        } else if appState.showSignUp || !appState.hasAnyAccounts() {
            // Show onboarding if user wants to sign up or no accounts exist
            OnboardingView(appState: appState)
        } else {
            // Show sign-in if accounts exist but user is not signed in
            SignInView(appState: appState)
        }
    }
}
