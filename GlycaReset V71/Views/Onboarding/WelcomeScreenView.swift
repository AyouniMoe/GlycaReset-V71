//
//  WelcomeScreenView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct WelcomeScreenView: View {
    @ObservedObject var appState: AppStateViewModel
    
    var body: some View {
        ZStack {
            // Light blue-grey background
            Color(red: 0.95, green: 0.96, blue: 0.98)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Title
                Text("Welcome to Your Diabetes\nJourney")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 16)
                
                // Description text
                Text("Whether you're working to reverse type 2 diabetes or have already achieved remission, this app will help you reach your health goals.")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 30)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                // Gradient button
                Button(action: {
                    appState.currentOnboardingStep = 1
                }) {
                    Text("LET'S BEGIN")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.2, green: 0.6, blue: 1.0), // Blue
                                    Color(red: 0.6, green: 0.4, blue: 0.9)  // Purple
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
    }
}

