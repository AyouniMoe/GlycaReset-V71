//
//  HealthKitManager.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import Foundation
import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    
    // Health data types we want to read
    private var readTypes: Set<HKObjectType> {
        var types: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .bloodGlucose)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]
        
        // Add mindful session for stress level estimation
        if let mindfulType = HKCategoryType.categoryType(forIdentifier: .mindfulSession) {
            types.insert(mindfulType)
        }
        
        return types
    }
    
    private init() {}
    
    // Check if HealthKit is available
    func isHealthKitAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    // Request authorization to read health data
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard isHealthKitAvailable() else {
            completion(false, NSError(domain: "HealthKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"]))
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    // Check authorization status
    func getAuthorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus {
        return healthStore.authorizationStatus(for: type)
    }
    
    // Read blood glucose data
    func readBloodGlucose(completion: @escaping ([Double]?, Error?) -> Void) {
        guard let glucoseType = HKQuantityType.quantityType(forIdentifier: .bloodGlucose) else {
            completion(nil, NSError(domain: "HealthKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Blood glucose type not available"]))
            return
        }
        
        let query = HKSampleQuery(sampleType: glucoseType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { query, samples, error in
            guard let samples = samples as? [HKQuantitySample] else {
                completion(nil, error)
                return
            }
            
            let glucoseValues = samples.map { sample in
                // HealthKit typically stores glucose in mmol/L
                // Get value in mmol/L and convert to mg/dL
                // Use the molar mass constant for glucose (180.15588 g/mol)
                let mmolPerLUnit = HKUnit.moleUnit(with: .milli, molarMass: HKUnitMolarMassBloodGlucose).unitDivided(by: HKUnit.liter())
                let valueInMmolPerL = sample.quantity.doubleValue(for: mmolPerLUnit)
                
                // Convert mmol/L to mg/dL: multiply by 18.0182
                // Normal range: 3.9-5.5 mmol/L = 70-100 mg/dL
                return valueInMmolPerL * 18.0182
            }
            
            DispatchQueue.main.async {
                completion(glucoseValues, nil)
            }
        }
        
        healthStore.execute(query)
    }
    
    // Read step count
    func readStepCount(completion: @escaping (Double?, Error?) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(nil, NSError(domain: "HealthKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Step count type not available"]))
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(nil, error)
                return
            }
            
            let steps = sum.doubleValue(for: HKUnit.count())
            DispatchQueue.main.async {
                completion(steps, nil)
            }
        }
        
        healthStore.execute(query)
    }
    
    // Read weight
    func readWeight(completion: @escaping (Double?, Error?) -> Void) {
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            completion(nil, NSError(domain: "HealthKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Weight type not available"]))
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { query, samples, error in
            guard let sample = samples?.first as? HKQuantitySample else {
                completion(nil, error)
                return
            }
            
            let weight = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            DispatchQueue.main.async {
                completion(weight, nil)
            }
        }
        
        healthStore.execute(query)
    }
    
    // Read heart rate
    func readHeartRate(completion: @escaping (Double?, Error?) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            completion(nil, NSError(domain: "HealthKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Heart rate type not available"]))
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { query, samples, error in
            guard let sample = samples?.first as? HKQuantitySample else {
                completion(nil, error)
                return
            }
            
            let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            DispatchQueue.main.async {
                completion(heartRate, nil)
            }
        }
        
        healthStore.execute(query)
    }
    
    // Read sleep data - returns quality score (0-10) based on duration and consistency
    func readSleepData(completion: @escaping (Double?, Error?) -> Void) {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(nil, NSError(domain: "HealthKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Sleep type not available"]))
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { query, samples, error in
            guard let samples = samples as? [HKCategorySample] else {
                completion(nil, error)
                return
            }
            
            // Calculate total sleep time
            var totalSleep: TimeInterval = 0
            var deepSleep: TimeInterval = 0
            var remSleep: TimeInterval = 0
            
            for sample in samples {
                let duration = sample.endDate.timeIntervalSince(sample.startDate)
                
                if sample.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue ||
                   sample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue {
                    totalSleep += duration
                } else if sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue {
                    totalSleep += duration
                    deepSleep += duration
                } else if sample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue {
                    totalSleep += duration
                    remSleep += duration
                }
            }
            
            let hours = totalSleep / 3600.0
            
            // Calculate quality score (0-10) based on:
            // - Duration (7-9 hours is ideal = 5 points)
            // - Deep sleep percentage (15-20% is ideal = 3 points)
            // - REM sleep percentage (20-25% is ideal = 2 points)
            var qualityScore: Double = 0
            
            // Duration score (0-5 points)
            if hours >= 7 && hours <= 9 {
                qualityScore += 5.0
            } else if hours >= 6 && hours < 7 {
                qualityScore += 3.0
            } else if hours > 9 && hours <= 10 {
                qualityScore += 4.0
            } else if hours >= 5 && hours < 6 {
                qualityScore += 2.0
            } else if hours > 10 {
                qualityScore += 3.0
            } else {
                qualityScore += 1.0
            }
            
            // Deep sleep score (0-3 points)
            if totalSleep > 0 {
                let deepSleepPercent = (deepSleep / totalSleep) * 100
                if deepSleepPercent >= 15 && deepSleepPercent <= 20 {
                    qualityScore += 3.0
                } else if deepSleepPercent >= 12 && deepSleepPercent < 15 {
                    qualityScore += 2.0
                } else if deepSleepPercent > 20 && deepSleepPercent <= 25 {
                    qualityScore += 2.5
                } else {
                    qualityScore += 1.0
                }
                
                // REM sleep score (0-2 points)
                let remSleepPercent = (remSleep / totalSleep) * 100
                if remSleepPercent >= 20 && remSleepPercent <= 25 {
                    qualityScore += 2.0
                } else if remSleepPercent >= 15 && remSleepPercent < 20 {
                    qualityScore += 1.5
                } else if remSleepPercent > 25 && remSleepPercent <= 30 {
                    qualityScore += 1.5
                } else {
                    qualityScore += 0.5
                }
            }
            
            // Cap at 10
            qualityScore = min(10.0, qualityScore)
            
            DispatchQueue.main.async {
                completion(qualityScore, nil)
            }
        }
        
        healthStore.execute(query)
    }
    
    // Read mood/stress data - uses mindful session as a proxy for stress management
    // Lower mindful sessions might indicate higher stress
    func readMoodData(completion: @escaping (Double?, Error?) -> Void) {
        // Since HealthKit doesn't have direct mood data, we'll use a combination approach
        // For now, return a default value and note that this would need integration with
        // a mood tracking app or manual input
        // Stress level is inverse: more mindfulness = lower stress
        // We'll calculate based on recent mindful sessions if available
        
        guard let mindfulType = HKCategoryType.categoryType(forIdentifier: .mindfulSession) else {
            // If mindful session not available, return nil (user can input manually)
            completion(nil, nil)
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        let predicate = HKQuery.predicateForSamples(withStart: weekAgo, end: now, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: mindfulType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { query, samples, error in
            guard let samples = samples as? [HKCategorySample] else {
                completion(nil, error)
                return
            }
            
            // Calculate total mindful minutes in the past week
            var totalMinutes: TimeInterval = 0
            for sample in samples {
                totalMinutes += sample.endDate.timeIntervalSince(sample.startDate) / 60.0
            }
            
            // Convert to stress level (0-10 scale)
            // More mindfulness = lower stress
            // 0-30 min/week = high stress (7-10)
            // 30-60 min/week = moderate stress (5-7)
            // 60-120 min/week = low stress (3-5)
            // 120+ min/week = very low stress (1-3)
            var stressLevel: Double = 5.0 // Default moderate
            
            if totalMinutes < 30 {
                stressLevel = 8.0 + (Double(totalMinutes) / 30.0) * 2.0 // 8-10
            } else if totalMinutes < 60 {
                stressLevel = 6.0 + ((Double(totalMinutes) - 30.0) / 30.0) * 1.0 // 6-7
            } else if totalMinutes < 120 {
                stressLevel = 4.0 + ((Double(totalMinutes) - 60.0) / 60.0) * 1.0 // 4-5
            } else {
                stressLevel = 2.0 + min(1.0, (Double(totalMinutes) - 120.0) / 120.0) // 2-3
            }
            
            DispatchQueue.main.async {
                completion(stressLevel, nil)
            }
        }
        
        healthStore.execute(query)
    }
    
    // Read step count for a specific date range
    func readStepCountForDateRange(startDate: Date, endDate: Date, completion: @escaping (Double?, Error?) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(nil, NSError(domain: "HealthKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Step count type not available"]))
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(nil, error)
                return
            }
            
            let steps = sum.doubleValue(for: HKUnit.count())
            DispatchQueue.main.async {
                completion(steps, nil)
            }
        }
        
        healthStore.execute(query)
    }
}

