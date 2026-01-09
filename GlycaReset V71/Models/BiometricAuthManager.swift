//
//  BiometricAuthManager.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import Foundation
import LocalAuthentication

class BiometricAuthManager {
    static let shared = BiometricAuthManager()
    
    private init() {}
    
    // Check if biometric authentication is available
    func isBiometricAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    // Get the type of biometric available (Face ID or Touch ID)
    func biometricType() -> String {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return "None"
        }
        
        if #available(iOS 11.0, *) {
            switch context.biometryType {
            case .faceID:
                return "Face ID"
            case .touchID:
                return "Touch ID"
            case .none:
                return "None"
            @unknown default:
                return "None"
            }
        }
        
        return "Touch ID"
    }
    
    // Authenticate with biometrics
    func authenticate(reason: String = "Sign in to your account", completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        context.localizedFallbackTitle = "Use Password"
        
        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: reason
        ) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
}
