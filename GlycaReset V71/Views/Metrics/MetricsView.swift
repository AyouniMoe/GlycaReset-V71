//
//  MetricsView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct MetricsView: View {
    @StateObject private var metricsManager = HealthMetricsManager.shared
    @State private var selectedMetric: MetricType?
    @State private var isSyncing = false
    @State private var syncError: String?
    
    var body: some View {
        ZStack {
            // Light blue-grey background
            Color(red: 0.95, green: 0.96, blue: 0.98)
                .ignoresSafeArea()
            
            ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Health Metrics")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("Track your reversal journey")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                        
                        // HbA1c Card (Large, Prominent)
                        if let hba1c = metricsManager.getLatestMetric(for: .hba1c) {
                            HbA1cCard(metric: hba1c, metricsManager: metricsManager)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                                .onTapGesture {
                                    selectedMetric = .hba1c
                                }
                        } else {
                            EmptyHbA1cCard(metricsManager: metricsManager)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                        }
                        
                        // Other Metrics Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 12) {
                            MetricCard(type: .fastingBloodGlucose, metricsManager: metricsManager)
                                .onTapGesture {
                                    selectedMetric = .fastingBloodGlucose
                                }
                            
                            MetricCard(type: .postprandialGlucose, metricsManager: metricsManager)
                                .onTapGesture {
                                    selectedMetric = .postprandialGlucose
                                }
                            
                            MetricCard(type: .weight, metricsManager: metricsManager)
                                .onTapGesture {
                                    selectedMetric = .weight
                                }
                            
                            MetricCard(type: .sleepQuality, metricsManager: metricsManager)
                                .onTapGesture {
                                    selectedMetric = .sleepQuality
                                }
                            
                            MetricCard(type: .stressLevel, metricsManager: metricsManager)
                                .onTapGesture {
                                    selectedMetric = .stressLevel
                                }
                            
                            MetricCard(type: .lifestyleAdherence, metricsManager: metricsManager)
                                .onTapGesture {
                                    selectedMetric = .lifestyleAdherence
                                }
                            
                            MetricCard(type: .dietAdherence, metricsManager: metricsManager)
                                .onTapGesture {
                                    selectedMetric = .dietAdherence
                                }
                            
                            MetricCard(type: .steps, metricsManager: metricsManager)
                                .onTapGesture {
                                    selectedMetric = .steps
                                }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        
                        // Sync from HealthKit button
                        VStack(spacing: 8) {
                            Button(action: {
                                syncFromHealthKit()
                            }) {
                                HStack {
                                    if isSyncing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.system(size: 16))
                                    }
                                    Text(isSyncing ? "Syncing..." : "Sync from HealthKit")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.2, green: 0.6, blue: 1.0),
                                            Color(red: 0.6, green: 0.4, blue: 0.9)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                            }
                            .disabled(isSyncing)
                            .opacity(isSyncing ? 0.6 : 1.0)
                            
                            if let error = syncError {
                                Text(error)
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 20)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        
                        // HbA1c Test Reminder Banner
                        if let reminder = metricsManager.hba1cReminder, !reminder.isCompleted {
                            HbA1cReminderBanner(reminder: reminder, metricsManager: metricsManager)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                        } else {
                            AddHbA1cReminderBanner(metricsManager: metricsManager)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                        }
                        
                        // Bottom spacing for tab bar
                        Spacer()
                            .frame(height: 100)
                    }
                }
            .sheet(item: Binding(
                get: { selectedMetric.map { MetricTypeWrapper(type: $0) } },
                set: { selectedMetric = $0?.type }
            )) { wrapper in
                MetricDetailView(metricType: wrapper.type, metricsManager: metricsManager)
            }
        }
    }
    
    private func syncFromHealthKit() {
        isSyncing = true
        syncError = nil
        
        metricsManager.syncFromHealthKit { success, error in
            isSyncing = false
            if success {
                syncError = nil
            } else {
                syncError = error?.localizedDescription ?? "Failed to sync from HealthKit"
            }
        }
    }
}

// Helper wrapper for sheet presentation
struct MetricTypeWrapper: Identifiable {
    let id = UUID()
    let type: MetricType
}

// MARK: - HbA1c Card

struct HbA1cCard: View {
    let metric: HealthMetric
    let metricsManager: HealthMetricsManager
    @State private var showReminderSheet = false
    
    var previousMetric: HealthMetric? {
        metricsManager.getPreviousMetric(for: .hba1c)
    }
    
    var trend: Double? {
        guard let previous = previousMetric else { return nil }
        return metric.value - previous.value
    }
    
    var status: String {
        metricsManager.getStatus(for: metric)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "drop.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                
                Text("HbA1c LEVEL")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.6))
            }
            
            HStack(alignment: .bottom, spacing: 8) {
                Text(String(format: "%.1f", metric.value))
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                
                Text("%")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
            
            if let trend = trend {
                HStack(spacing: 4) {
                    Image(systemName: trend < 0 ? "arrow.down" : "arrow.up")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                    
                    Text(String(format: "%.1f%% from last test", abs(trend)))
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
            }
            
            HStack {
                Spacer()
                
                Text(status)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.3))
                    )
            }
            
            Text("Target: \(String(format: "%.1f", metricsManager.getTarget(for: .hba1c)))%")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.9))
            
            // 6-Year Trend
            VStack(alignment: .leading, spacing: 12) {
                Text("6-Year Trend")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(getTrendData(), id: \.year) { data in
                            VStack(spacing: 4) {
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: 20, height: CGFloat(data.value * 10))
                                
                                Text(data.year)
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Text(String(format: "%.1f", data.value))
                                    .font(.system(size: 9))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }
                }
            }
            .padding(.top, 8)
            
            HStack {
                Text("Tap to view details")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.6, blue: 1.0),
                    Color(red: 0.4, green: 0.7, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
    
    private func getTrendData() -> [(year: String, value: Double)] {
        // Get metrics from the past 6 years (72 months)
        let metrics = metricsManager.getMetrics(for: .hba1c, months: 72)
        let calendar = Calendar.current
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        
        var data: [(year: String, value: Double)] = []
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        
        // Group metrics by year and get the latest value for each year
        for yearOffset in 0..<6 {
            let targetYear = currentYear - (5 - yearOffset)
            let yearStr = String(targetYear)
            
            // Get all metrics for this year
            let yearMetrics = metrics.filter { calendar.component(.year, from: $0.date) == targetYear }
            
            if let latestMetric = yearMetrics.sorted(by: { $0.date > $1.date }).first {
                // Use the latest value for this year
                data.append((year: yearStr, value: latestMetric.value))
            } else if yearOffset == 5, let latest = metrics.sorted(by: { $0.date > $1.date }).first {
                // If current year has no data, use the most recent available value
                data.append((year: yearStr, value: latest.value))
            }
        }
        
        // If no data at all, return empty array (don't show sample data for years)
        return data
    }
}

struct EmptyHbA1cCard: View {
    @ObservedObject var metricsManager: HealthMetricsManager
    @State private var showInput = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "drop.fill")
                .font(.system(size: 50))
                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.5))
            
            Text("No HbA1c data yet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.gray)
            
            Text("Add your first reading to start tracking")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button(action: {
                showInput = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                    
                    Text("Add HbA1c Result")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.2, green: 0.6, blue: 1.0),
                            Color(red: 0.4, green: 0.7, blue: 1.0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color.white)
        .cornerRadius(16)
        .sheet(isPresented: $showInput) {
            HbA1cManualInputView(metricsManager: metricsManager)
        }
    }
}

// MARK: - Metric Card

struct MetricCard: View {
    let type: MetricType
    let metricsManager: HealthMetricsManager
    
    var latestMetric: HealthMetric? {
        metricsManager.getLatestMetric(for: type)
    }
    
    var previousMetric: HealthMetric? {
        metricsManager.getPreviousMetric(for: type)
    }
    
    var trend: Double? {
        guard let latest = latestMetric,
              let previous = previousMetric else { return nil }
        return latest.value - previous.value
    }
    
    var status: String {
        guard let metric = latestMetric else { return "No data" }
        return metricsManager.getStatus(for: metric)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: type.displayInfo.icon)
                    .font(.system(size: 20))
                    .foregroundColor(type.displayInfo.color.solidColor)
                
                Spacer()
            }
            
            Text(type.displayInfo.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
            
            if let metric = latestMetric {
                HStack(alignment: .bottom, spacing: 4) {
                    Text(formatValue(metric.value))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    
                    if !type.displayInfo.unit.isEmpty {
                        Text(type.displayInfo.unit)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                
                if let trend = trend {
                    HStack(spacing: 4) {
                        Image(systemName: trend < 0 ? "arrow.down" : "arrow.up")
                            .font(.system(size: 10))
                            .foregroundColor(.green)
                        
                        Text(formatTrend(trend))
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                    }
                }
                
                Text(status)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .stroke(Color.green, lineWidth: 1)
                    )
            } else {
                Text("No data")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func formatValue(_ value: Double) -> String {
        if type == .sleepQuality || type == .stressLevel {
            return String(format: "%.1f", value)
        } else if type == .lifestyleAdherence || type == .dietAdherence {
            return String(format: "%.0f", value)
        } else if type == .steps {
            // Format steps with comma separator
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.0f", value)
        } else {
            return String(format: "%.0f", value)
        }
    }
    
    private func formatTrend(_ trend: Double) -> String {
        let absTrend = abs(trend)
        if type == .sleepQuality || type == .stressLevel {
            return String(format: "%.1f", absTrend)
        } else {
            return String(format: "%.0f", absTrend)
        }
    }
}

// MARK: - HbA1c Reminder Banner

struct HbA1cReminderBanner: View {
    let reminder: HbA1cTestReminder
    let metricsManager: HealthMetricsManager
    @State private var showReminderSheet = false
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 24))
                .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Next HbA1c Test")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                
                Text("Scheduled for \(dateFormatter.string(from: reminder.scheduledDate))")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {
                showReminderSheet = true
            }) {
                Image(systemName: "pencil")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .background(Color(red: 1.0, green: 0.95, blue: 0.8))
        .cornerRadius(12)
        .sheet(isPresented: $showReminderSheet) {
            HbA1cReminderSheet(metricsManager: metricsManager)
        }
    }
}

struct AddHbA1cReminderBanner: View {
    @ObservedObject var metricsManager: HealthMetricsManager
    @State private var showReminderSheet = false
    
    var body: some View {
        Button(action: {
            showReminderSheet = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                
                Text("Add HbA1c Test Reminder")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                
                Spacer()
            }
            .padding(16)
            .background(Color(red: 1.0, green: 0.95, blue: 0.8))
            .cornerRadius(12)
        }
        .sheet(isPresented: $showReminderSheet) {
            HbA1cReminderSheet(metricsManager: metricsManager, isNewReminder: true)
        }
    }
}

struct HbA1cReminderSheet: View {
    @ObservedObject var metricsManager: HealthMetricsManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedDate = Date()
    let isNewReminder: Bool
    
    init(metricsManager: HealthMetricsManager, isNewReminder: Bool = false) {
        self.metricsManager = metricsManager
        self.isNewReminder = isNewReminder
        if let reminder = metricsManager.hba1cReminder {
            _selectedDate = State(initialValue: reminder.scheduledDate)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Schedule HbA1c Test")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.top, 20)
                
                DatePicker("Test Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                
                Spacer()
                
                HStack(spacing: 16) {
                    if !isNewReminder {
                        Button(action: {
                            metricsManager.removeHbA1cReminder()
                            dismiss()
                        }) {
                            Text("Remove Reminder")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red, lineWidth: 1)
                                )
                                .cornerRadius(12)
                        }
                    }
                    
                    Button(action: {
                        metricsManager.setHbA1cReminder(date: selectedDate)
                        dismiss()
                    }) {
                        Text("Save")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.2, green: 0.6, blue: 1.0),
                                        Color(red: 0.6, green: 0.4, blue: 0.9)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

