//
//  LocalAccountManager.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import Foundation

struct UserAccount: Codable {
    let email: String
    let username: String
    let password: String // In production, this should be hashed
    let journeyType: String
    let medicationStatus: String?
    let hba1cValue: Double?
    let diagnosisYear: Int?
    let weightLossCommitment: String?
    let insulinDependency: String?
    let a1cStatus: String?
    let advancedComplications: String?
    let createdAt: Date
}

class LocalAccountManager {
    static let shared = LocalAccountManager()
    private let accountsKey = "stored_accounts"
    private let currentUserKey = "current_user"
    
    private init() {}
    
    // Get all stored accounts
    func getAllAccounts() -> [UserAccount] {
        guard let data = UserDefaults.standard.data(forKey: accountsKey),
              let accounts = try? JSONDecoder().decode([UserAccount].self, from: data) else {
            return []
        }
        return accounts
    }
    
    // Check if username is unique
    func isUsernameUnique(_ username: String) -> Bool {
        let accounts = getAllAccounts()
        return !accounts.contains { $0.username.lowercased() == username.lowercased() }
    }
    
    // Check if email is unique
    func isEmailUnique(_ email: String) -> Bool {
        let accounts = getAllAccounts()
        return !accounts.contains { $0.email.lowercased() == email.lowercased() }
    }
    
    // Save a new account
    func saveAccount(_ account: UserAccount) -> Bool {
        var accounts = getAllAccounts()
        
        // Check for duplicates
        if !isUsernameUnique(account.username) || !isEmailUnique(account.email) {
            return false
        }
        
        accounts.append(account)
        
        if let encoded = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(encoded, forKey: accountsKey)
            // Don't automatically save as current user - user must sign in explicitly
            return true
        }
        return false
    }
    
    // Get current logged-in user
    func getCurrentUser() -> UserAccount? {
        guard let data = UserDefaults.standard.data(forKey: currentUserKey),
              let account = try? JSONDecoder().decode(UserAccount.self, from: data) else {
            return nil
        }
        return account
    }
    
    // Clear current user (for logout)
    func clearCurrentUser() {
        UserDefaults.standard.removeObject(forKey: currentUserKey)
    }
    
    // Sign in with username/email and password
    func signIn(usernameOrEmail: String, password: String) -> UserAccount? {
        let accounts = getAllAccounts()
        
        // Find account by username or email
        let account = accounts.first { acc in
            (acc.username.lowercased() == usernameOrEmail.lowercased() ||
             acc.email.lowercased() == usernameOrEmail.lowercased()) &&
            acc.password == password // In production, compare hashed passwords
        }
        
        if let account = account {
            // Save as current user
            if let currentUserData = try? JSONEncoder().encode(account) {
                UserDefaults.standard.set(currentUserData, forKey: currentUserKey)
            }
            return account
        }
        
        return nil
    }
    
    // Check if any accounts exist (to determine if user should see sign-in or onboarding)
    func hasAnyAccounts() -> Bool {
        return !getAllAccounts().isEmpty
    }
}

