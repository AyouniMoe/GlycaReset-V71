//
//  CreateAccountView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct CreateAccountView: View {
    @ObservedObject var appState: AppStateViewModel
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, username, password
    }
    
    var isValidForm: Bool {
        !email.isEmpty && !username.isEmpty && !password.isEmpty &&
        password.count >= 6 &&
        appState.emailError == nil && appState.usernameError == nil
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
                                
                                // Progress fill - different for each journey type
                                let progressWidth = appState.selectedJourneyType == .successfullyReversed 
                                    ? geometry.size.width * 5 / 6  // Step 5 of 6
                                    : geometry.size.width * 7 / 8  // Step 7 of 8
                                
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
                                    .frame(width: progressWidth, height: 4)
                            }
                        }
                        .frame(height: 4)
                        .padding(.horizontal, 30)
                        
                        // Step indicator
                        HStack {
                            let stepText = appState.selectedJourneyType == .successfullyReversed 
                                ? "Step 5 of 6"
                                : "Step 7 of 8"
                            Text(stepText)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(.horizontal, 30)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                    
                    // User icon with plus
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.8, green: 0.9, blue: 1.0)) // Light blue
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .stroke(Color(red: 0.2, green: 0.3, blue: 0.8), lineWidth: 2) // Dark blue outline
                            )
                        
                        HStack(spacing: -4) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 30))
                                .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.8))
                            
                            Text("+")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.8))
                        }
                    }
                    .padding(.bottom, 30)
                    
                    // Title
                    Text("Create Your Account")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 12)
                    
                    // Subtitle
                    Text("Set up your account to start tracking your progress.")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 40)
                    
                    // Input fields
                    VStack(spacing: 24) {
                        // Email field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email Address")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            
                            TextField("your.email@example.com", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            appState.emailError != nil ? Color.red : Color.gray.opacity(0.3),
                                            lineWidth: 1
                                        )
                                )
                                .cornerRadius(12)
                                .focused($focusedField, equals: .email)
                                .onChange(of: email) { oldValue, newValue in
                                    if newValue.isEmpty {
                                        appState.emailError = nil
                                    } else {
                                        _ = appState.validateEmail(newValue)
                                    }
                                }
                            
                            if let error = appState.emailError {
                                Text(error)
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Username field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            
                            TextField("yourusername", text: $username)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            appState.usernameError != nil ? Color.red : Color.gray.opacity(0.3),
                                            lineWidth: 1
                                        )
                                )
                                .cornerRadius(12)
                                .focused($focusedField, equals: .username)
                                .onChange(of: username) { oldValue, newValue in
                                    if newValue.isEmpty {
                                        appState.usernameError = nil
                                    } else {
                                        _ = appState.validateUsername(newValue)
                                    }
                                }
                            
                            if let error = appState.usernameError {
                                Text(error)
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            
                            HStack {
                                if showPassword {
                                    TextField("yourpassword", text: $password)
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                } else {
                                    SecureField("yourpassword", text: $password)
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                }
                                
                                Button(action: {
                                    showPassword.toggle()
                                }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .cornerRadius(12)
                            .focused($focusedField, equals: .password)
                            
                            if !password.isEmpty && password.count < 6 {
                                Text("Password must be at least 6 characters")
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                    
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
                                        .stroke(Color(red: 0.2, green: 0.7, blue: 0.4), lineWidth: 1)
                                )
                                .cornerRadius(16)
                        }
                        
                        // Continue button
                        Button(action: {
                            if appState.createAccount(email: email, username: username, password: password) {
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
                                            Color(red: 0.4, green: 0.7, blue: 1.0), // Light blue
                                            Color(red: 0.7, green: 0.5, blue: 1.0)  // Light purple
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                        }
                        .disabled(!isValidForm)
                        .opacity(isValidForm ? 1.0 : 0.5)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                }
            }
        }
        .onTapGesture {
            focusedField = nil
        }
    }
}

