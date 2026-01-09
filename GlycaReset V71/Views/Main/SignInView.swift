//
//  SignInView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI
import LocalAuthentication

struct SignInView: View {
    @ObservedObject var appState: AppStateViewModel
    @State private var usernameOrEmail: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var signInError: String?
    @State private var showPasswordForm: Bool = false
    @State private var isAuthenticating: Bool = false
    @FocusState private var focusedField: Field?
    
    private let biometricManager = BiometricAuthManager.shared
    private var isBiometricAvailable: Bool {
        biometricManager.isBiometricAvailable()
    }
    private var biometricType: String {
        biometricManager.biometricType()
    }
    private var hasAccounts: Bool {
        LocalAccountManager.shared.hasAnyAccounts()
    }
    
    enum Field {
        case usernameOrEmail, password
    }
    
    var isValidForm: Bool {
        !usernameOrEmail.isEmpty && !password.isEmpty
    }
    
    var body: some View {
        ZStack {
            // Light blue-grey background
            Color(red: 0.95, green: 0.96, blue: 0.98)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 80)
                    
                    // App icon/logo area
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.2, green: 0.6, blue: 1.0), // Blue
                                        Color(red: 0.6, green: 0.4, blue: 0.9)  // Purple
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "heart.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 40)
                    
                    // Title
                    Text("Welcome Back")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 12)
                    
                    // Subtitle
                    Text("Sign in to continue your diabetes journey")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 50)
                    
                    // Face ID / Touch ID Button (Primary Sign-in Method)
                    if isBiometricAvailable && hasAccounts {
                        VStack(spacing: 20) {
                            Button(action: {
                                authenticateWithBiometric()
                            }) {
                                VStack(spacing: 12) {
                                    Image(systemName: biometricType == "Face ID" ? "faceid" : "touchid")
                                        .font(.system(size: 50))
                                        .foregroundColor(.white)
                                    
                                    Text("Sign in with \(biometricType)")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 24)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.2, green: 0.6, blue: 1.0), // Blue
                                            Color(red: 0.6, green: 0.4, blue: 0.9)  // Purple
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                            }
                            .disabled(isAuthenticating)
                            .opacity(isAuthenticating ? 0.6 : 1.0)
                            
                            if isAuthenticating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.2, green: 0.6, blue: 1.0)))
                            }
                            
                            // Divider with "or" text
                            HStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                                
                                Text("or")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 16)
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                            .padding(.horizontal, 30)
                            .padding(.vertical, 20)
                            
                            // Toggle to show password form
                            Button(action: {
                                withAnimation {
                                    showPasswordForm.toggle()
                                }
                            }) {
                                Text(showPasswordForm ? "Use \(biometricType) instead" : "Sign in with password")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 1.0))
                            }
                            .padding(.bottom, 10)
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 20)
                    }
                    
                    // Input fields (shown if biometric not available or user chooses password)
                    if !isBiometricAvailable || !hasAccounts || showPasswordForm {
                        VStack(spacing: 24) {
                            // Username or Email field
                            VStack(alignment: .leading, spacing: 8) {
                            Text("Username or Email")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            
                            TextField("username or email", text: $usernameOrEmail)
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
                                            signInError != nil ? Color.red : Color.gray.opacity(0.3),
                                            lineWidth: 1
                                        )
                                )
                                .cornerRadius(12)
                                .focused($focusedField, equals: .usernameOrEmail)
                                .onChange(of: usernameOrEmail) { oldValue, newValue in
                                    signInError = nil
                                }
                        }
                        
                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            
                            HStack {
                                if showPassword {
                                    TextField("password", text: $password)
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                } else {
                                    SecureField("password", text: $password)
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
                                    .stroke(
                                        signInError != nil ? Color.red : Color.gray.opacity(0.3),
                                        lineWidth: 1
                                    )
                            )
                            .cornerRadius(12)
                            .focused($focusedField, equals: .password)
                            .onChange(of: password) { oldValue, newValue in
                                signInError = nil
                            }
                            
                            if let error = signInError {
                                Text(error)
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                            }
                        }
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 40)
                        
                        // Sign in button
                        Button(action: {
                            signIn()
                        }) {
                        Text("SIGN IN")
                            .font(.system(size: 16, weight: .bold))
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
                        .disabled(!isValidForm)
                        .opacity(isValidForm ? 1.0 : 0.5)
                        .padding(.bottom, 30)
                    }
                    
                    // Sign up link
                    HStack {
                        Text("Don't have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            appState.showSignUp = true
                        }) {
                            Text("Sign Up")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 1.0))
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .onTapGesture {
            focusedField = nil
        }
        .onAppear {
            // Auto-trigger Face ID if available and accounts exist
            if isBiometricAvailable && hasAccounts && !showPasswordForm {
                // Small delay to let the view appear first
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    authenticateWithBiometric()
                }
            }
        }
    }
    
    private func authenticateWithBiometric() {
        isAuthenticating = true
        signInError = nil
        
        appState.signInWithBiometric { success, errorMessage in
            isAuthenticating = false
            if !success {
                signInError = errorMessage ?? "Biometric authentication failed"
                // Show password form if biometric fails
                if errorMessage?.contains("No account") == false {
                    showPasswordForm = true
                }
            }
        }
    }
    
    private func signIn() {
        signInError = nil
        
        // Attempt to sign in
        if appState.signIn(usernameOrEmail: usernameOrEmail, password: password) {
            // Sign in successful - appState will handle navigation
        } else {
            signInError = "Invalid username/email or password"
        }
    }
}

