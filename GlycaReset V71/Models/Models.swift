//
//  Models.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import Foundation

// MARK: - Journey Types
enum JourneyType {
    case workingOnReversal
    case successfullyReversed
}

// MARK: - Medication Status
enum MedicationStatus {
    case noMedication
    case onMedication
}

// MARK: - Weight Loss Commitment
enum WeightLossCommitment {
    case committed
    case notCommitted
}

// MARK: - Insulin Dependency
enum InsulinDependency {
    case notDependent
    case dependent
}

// MARK: - A1C Status
enum A1CStatus {
    case belowThreshold
    case aboveThreshold
}

// MARK: - Advanced Complications
enum AdvancedComplications {
    case noComplications
    case hasComplications
}

