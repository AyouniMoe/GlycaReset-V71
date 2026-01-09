//
//  HealthMetricsManager.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import Foundation
import SwiftUI
import Combine

class HealthMetricsManager: ObservableObject {
    static let shared = HealthMetricsManager()
    
    @Published var metrics: [HealthMetric] = []
    @Published var targets: [MetricTarget] = []
    @Published var hba1cReminder: HbA1cTestReminder?
    
    private let metricsKey = "health_metrics"
    private let targetsKey = "metric_targets"
    private let reminderKey = "hba1c_reminder"
    
    private init() {
        loadMetrics()
        loadTargets()
        loadReminder()
        initializeDefaultTargets()
    }
    
    // MARK: - Metrics Management
    
    func addMetric(_ metric: HealthMetric) {
        metrics.append(metric)
        saveMetrics()
    }
    
    func getLatestMetric(for type: MetricType) -> HealthMetric? {
        return metrics
            .filter { $0.type == type }
            .sorted { $0.date > $1.date }
            .first
    }
    
    func getMetrics(for type: MetricType, months: Int = 6) -> [HealthMetric] {
        let cutoffDate = Calendar.current.date(byAdding: .month, value: -months, to: Date()) ?? Date()
        return metrics
            .filter { $0.type == type && $0.date >= cutoffDate }
            .sorted { $0.date < $1.date }
    }
    
    func getPreviousMetric(for type: MetricType) -> HealthMetric? {
        guard let latest = getLatestMetric(for: type) else { return nil }
        return metrics
            .filter { $0.type == type && $0.date < latest.date }
            .sorted { $0.date > $1.date }
            .first
    }
    
    func hasMetric(for type: MetricType, date: Date) -> Bool {
        let calendar = Calendar.current
        return metrics.contains { $0.type == type && calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    // MARK: - Targets Management
    
    func setTarget(for type: MetricType, value: Double) {
        if let index = targets.firstIndex(where: { $0.type == type }) {
            targets[index] = MetricTarget(type: type, targetValue: value)
        } else {
            targets.append(MetricTarget(type: type, targetValue: value))
        }
        saveTargets()
    }
    
    func getTarget(for type: MetricType) -> Double {
        if let target = targets.first(where: { $0.type == type }) {
            return target.targetValue
        }
        return type.displayInfo.targetValue
    }
    
    private func initializeDefaultTargets() {
        if targets.isEmpty {
            for metricType in [MetricType.hba1c, .fastingBloodGlucose, .postprandialGlucose, .sleepQuality, .stressLevel, .lifestyleAdherence, .dietAdherence] {
                setTarget(for: metricType, value: metricType.displayInfo.targetValue)
            }
        }
    }
    
    // MARK: - Reminder Management
    
    func setHbA1cReminder(date: Date) {
        hba1cReminder = HbA1cTestReminder(scheduledDate: date)
        saveReminder()
    }
    
    func removeHbA1cReminder() {
        hba1cReminder = nil
        saveReminder()
    }
    
    // MARK: - HealthKit Sync
    
    func syncFromHealthKit(completion: @escaping (Bool, Error?) -> Void) {
        let healthKitManager = HealthKitManager.shared
        
        guard healthKitManager.isHealthKitAvailable() else {
            completion(false, NSError(domain: "HealthKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available"]))
            return
        }
        
        var syncCount = 0
        let totalSyncs = 4 // weight, sleep, stress, steps
        var hasError: Error?
        
        // Sync Weight
        healthKitManager.readWeight { [weak self] weight, error in
            if let weight = weight {
                // Convert kg to lbs
                let weightInLbs = weight * 2.20462
                let metric = HealthMetric(type: .weight, value: weightInLbs, date: Date())
                self?.addMetric(metric)
            }
            syncCount += 1
            if error != nil && hasError == nil {
                hasError = error
            }
            if syncCount == totalSyncs {
                completion(hasError == nil, hasError)
            }
        }
        
        // Sync Sleep Quality
        healthKitManager.readSleepData { [weak self] quality, error in
            if let quality = quality {
                let metric = HealthMetric(type: .sleepQuality, value: quality, date: Date())
                self?.addMetric(metric)
            }
            syncCount += 1
            if error != nil && hasError == nil {
                hasError = error
            }
            if syncCount == totalSyncs {
                completion(hasError == nil, hasError)
            }
        }
        
        // Sync Stress Level (from mood/mindful sessions)
        healthKitManager.readMoodData { [weak self] stress, error in
            if let stress = stress {
                let metric = HealthMetric(type: .stressLevel, value: stress, date: Date())
                self?.addMetric(metric)
            }
            syncCount += 1
            if error != nil && hasError == nil {
                hasError = error
            }
            if syncCount == totalSyncs {
                completion(hasError == nil, hasError)
            }
        }
        
        // Sync Steps
        healthKitManager.readStepCount { [weak self] steps, error in
            if let steps = steps {
                let metric = HealthMetric(type: .steps, value: steps, date: Date())
                self?.addMetric(metric)
            }
            syncCount += 1
            if error != nil && hasError == nil {
                hasError = error
            }
            if syncCount == totalSyncs {
                completion(hasError == nil, hasError)
            }
        }
    }
    
    // MARK: - Status Calculation
    
    func getStatus(for metric: HealthMetric) -> String {
        switch metric.type {
        case .hba1c:
            if metric.value < 5.7 {
                return "NORMAL"
            } else if metric.value < 6.5 {
                return "PREDIABETES"
            } else {
                return "DIABETES"
            }
        case .fastingBloodGlucose:
            if metric.value < 100 {
                return "NORMAL RANGE"
            } else if metric.value < 126 {
                return "PREDIABETES"
            } else {
                return "DIABETES"
            }
        case .postprandialGlucose:
            if metric.value < 140 {
                return "EXCELLENT"
            } else if metric.value < 200 {
                return "PREDIABETES"
            } else {
                return "DIABETES"
            }
        case .weight:
            return "ON TRACK"
        case .sleepQuality:
            if metric.value >= 8 {
                return "EXCELLENT"
            } else if metric.value >= 7 {
                return "GOOD"
            } else {
                return "NEEDS IMPROVEMENT"
            }
        case .stressLevel:
            if metric.value <= 3 {
                return "LOW"
            } else if metric.value <= 5 {
                return "MODERATE"
            } else {
                return "HIGH"
            }
        case .lifestyleAdherence, .dietAdherence:
            if metric.value >= 90 {
                return "EXCELLENT"
            } else if metric.value >= 75 {
                return "VERY GOOD"
            } else if metric.value >= 60 {
                return "GOOD"
            } else {
                return "NEEDS IMPROVEMENT"
            }
        case .steps:
            if metric.value >= 10000 {
                return "EXCELLENT"
            } else if metric.value >= 7500 {
                return "VERY GOOD"
            } else if metric.value >= 5000 {
                return "GOOD"
            } else {
                return "NEEDS IMPROVEMENT"
            }
        }
    }
    
    func getProgressPercentage(for metric: HealthMetric) -> Double {
        let target = getTarget(for: metric.type)
        let current = metric.value
        
        switch metric.type {
        case .hba1c, .fastingBloodGlucose, .postprandialGlucose, .stressLevel:
            // For metrics where lower is better
            if current <= target {
                return 100.0
            }
            // Calculate progress (this is simplified - you may want more sophisticated logic)
            let range = target * 2 // Assume target is roughly half of "bad" value
            return max(0, min(100, (1 - (current - target) / range) * 100))
        case .sleepQuality, .lifestyleAdherence, .dietAdherence, .steps:
            // For metrics where higher is better
            return min(100, (current / target) * 100)
        case .weight:
            // Weight is more complex - would need starting weight
            return 67.0 // Placeholder
        }
    }
    
    // MARK: - Persistence
    
    private func saveMetrics() {
        if let encoded = try? JSONEncoder().encode(metrics) {
            UserDefaults.standard.set(encoded, forKey: metricsKey)
        }
    }
    
    private func loadMetrics() {
        if let data = UserDefaults.standard.data(forKey: metricsKey),
           let decoded = try? JSONDecoder().decode([HealthMetric].self, from: data) {
            metrics = decoded
        }
    }
    
    private func saveTargets() {
        if let encoded = try? JSONEncoder().encode(targets) {
            UserDefaults.standard.set(encoded, forKey: targetsKey)
        }
    }
    
    private func loadTargets() {
        if let data = UserDefaults.standard.data(forKey: targetsKey),
           let decoded = try? JSONDecoder().decode([MetricTarget].self, from: data) {
            targets = decoded
        }
    }
    
    private func saveReminder() {
        if let reminder = hba1cReminder,
           let encoded = try? JSONEncoder().encode(reminder) {
            UserDefaults.standard.set(encoded, forKey: reminderKey)
        } else {
            UserDefaults.standard.removeObject(forKey: reminderKey)
        }
    }
    
    private func loadReminder() {
        if let data = UserDefaults.standard.data(forKey: reminderKey),
           let decoded = try? JSONDecoder().decode(HbA1cTestReminder.self, from: data) {
            hba1cReminder = decoded
        }
    }
}

