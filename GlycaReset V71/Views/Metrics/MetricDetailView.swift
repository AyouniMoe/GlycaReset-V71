//
//  MetricDetailView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct MetricDetailView: View {
    let metricType: MetricType
    @ObservedObject var metricsManager: HealthMetricsManager
    @Environment(\.dismiss) var dismiss
    @State private var showHbA1cInput = false
    
    var latestMetric: HealthMetric? {
        metricsManager.getLatestMetric(for: metricType)
    }
    
    var previousMetric: HealthMetric? {
        metricsManager.getPreviousMetric(for: metricType)
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
    
    var progress: Double {
        guard let metric = latestMetric else { return 0 }
        return metricsManager.getProgressPercentage(for: metric)
    }
    
    var target: Double {
        metricsManager.getTarget(for: metricType)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Light blue-grey background
                Color(red: 0.95, green: 0.96, blue: 0.98)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        if let metric = latestMetric {
                            // Current Level Card
                            CurrentLevelCard(
                                metric: metric,
                                metricType: metricType,
                                trend: trend,
                                status: status,
                                target: target,
                                progress: progress
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            
                            // What is [Metric]? Card
                            InfoCard(
                                title: "What is \(metricType.displayInfo.title)?",
                                description: metricType.displayInfo.description
                            )
                            .padding(.horizontal, 20)
                            
                            // 6-Year Trend Card (or HbA1c specific trend)
                            if metricType == .hba1c {
                                HbA1cTrendGraphView(
                                    metrics: metricsManager.getMetrics(for: .hba1c, months: 72),
                                    target: target
                                )
                                .padding(.horizontal, 20)
                            } else {
                                TrendCard(
                                    metricType: metricType,
                                    metricsManager: metricsManager
                                )
                                .padding(.horizontal, 20)
                            }
                            
                            // Analysis Card
                            AnalysisCard(
                                metric: metric,
                                metricType: metricType,
                                trend: trend,
                                target: target
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                            
                            // Add HbA1c Button (only for HbA1c)
                            if metricType == .hba1c {
                                AddHbA1cButton()
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 20)
                            }
                        } else {
                            // Empty state
                            VStack(spacing: 20) {
                                Image(systemName: metricType.displayInfo.icon)
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                
                                Text("No data available")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.gray)
                                
                                Text("Add your first reading to start tracking")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                
                                // Add button for HbA1c
                                if metricType == .hba1c {
                                    AddHbA1cButton()
                                        .padding(.top, 20)
                                }
                            }
                            .padding(40)
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .navigationTitle(metricType.displayInfo.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if metricType == .hba1c {
                        Button(action: {
                            showHbA1cInput = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 1.0))
                        }
                    }
                }
            }
            .sheet(isPresented: $showHbA1cInput) {
                HbA1cManualInputView(metricsManager: metricsManager)
            }
        }
    }
}

// MARK: - Add HbA1c Button

struct AddHbA1cButton: View {
    @State private var showInput = false
    
    var body: some View {
        Button(action: {
            showInput = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                
                Text("Add HbA1c Result")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
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
        .sheet(isPresented: $showInput) {
            HbA1cManualInputView(metricsManager: HealthMetricsManager.shared)
        }
    }
}

// MARK: - Current Level Card

struct CurrentLevelCard: View {
    let metric: HealthMetric
    let metricType: MetricType
    let trend: Double?
    let status: String
    let target: Double
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: metricType.displayInfo.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                
                Text("CURRENT LEVEL")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.6))
            }
            
            HStack(alignment: .bottom, spacing: 4) {
                Text(formatValue(metric.value))
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                
                if !metricType.displayInfo.unit.isEmpty {
                    Text(metricType.displayInfo.unit)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            if let trend = trend {
                HStack(spacing: 4) {
                    Image(systemName: shouldShowDownArrow() ? "arrow.down" : "arrow.up")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                    
                    Text(formatTrend(trend))
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
            
            Text("Target: \(formatValue(target))\(metricType.displayInfo.unit)")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.9))
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress to target")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                    
                    Text("\(Int(progress))%")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white)
                            .frame(width: geometry.size.width * CGFloat(progress / 100), height: 8)
                    }
                }
                .frame(height: 8)
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [metricType.displayInfo.color.gradientColors.0, metricType.displayInfo.color.gradientColors.1]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
    
    private func shouldShowDownArrow() -> Bool {
        switch metricType {
        case .hba1c, .fastingBloodGlucose, .postprandialGlucose, .stressLevel, .weight:
            return trend ?? 0 < 0
        case .sleepQuality, .lifestyleAdherence, .dietAdherence, .steps:
            return trend ?? 0 > 0
        }
    }
    
    private func formatValue(_ value: Double) -> String {
        if metricType == .sleepQuality || metricType == .stressLevel {
            return String(format: "%.1f", value)
        } else if metricType == .lifestyleAdherence || metricType == .dietAdherence {
            return String(format: "%.0f", value)
        } else if metricType == .steps {
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
        let prefix = shouldShowDownArrow() ? "-" : "+"
        
        if metricType == .sleepQuality || metricType == .stressLevel {
            return "\(prefix)\(String(format: "%.1f", absTrend))\(metricType.displayInfo.unit) from previous"
        } else if metricType == .fastingBloodGlucose || metricType == .postprandialGlucose {
            return "\(prefix)\(String(format: "%.0f", absTrend))mg/dL from previous"
        } else if metricType == .weight {
            return "\(prefix)\(String(format: "%.0f", absTrend))lbs from previous"
        } else if metricType == .hba1c {
            return "\(prefix)\(String(format: "%.1f", absTrend))% from previous"
        } else if metricType == .steps {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let formatted = formatter.string(from: NSNumber(value: absTrend)) ?? String(format: "%.0f", absTrend)
            return "\(prefix)\(formatted) steps from previous"
        } else {
            return "\(prefix)\(String(format: "%.0f", absTrend))% from previous"
        }
    }
}

// MARK: - Info Card

struct InfoCard: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            
            Text(description)
                .font(.system(size: 14))
                .foregroundColor(.black)
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.92, green: 0.96, blue: 0.98))
        .cornerRadius(12)
    }
}

// MARK: - Trend Card

struct TrendCard: View {
    let metricType: MetricType
    @ObservedObject var metricsManager: HealthMetricsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("6-Month Trend")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            
            // Simple line/scatter plot representation
            VStack(spacing: 12) {
                let trendData = getTrendData()
                let maxValue = trendData.map { $0.value }.max() ?? 1
                let minValue = trendData.map { $0.value }.min() ?? 0
                let range = maxValue - minValue
                let target = metricsManager.getTarget(for: metricType)
                
                GeometryReader { geometry in
                    ZStack {
                        // Target line
                        Path { path in
                            let yPosition = geometry.size.height - (CGFloat((target - minValue) / range) * geometry.size.height)
                            path.move(to: CGPoint(x: 0, y: yPosition))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: yPosition))
                        }
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        .foregroundColor(.green)
                        
                        // Data points and line
                        Path { path in
                            for (index, data) in trendData.enumerated() {
                                let xPosition = CGFloat(index) / CGFloat(max(trendData.count - 1, 1)) * geometry.size.width
                                let yPosition = geometry.size.height - (CGFloat((data.value - minValue) / range) * geometry.size.height)
                                
                                if index == 0 {
                                    path.move(to: CGPoint(x: xPosition, y: yPosition))
                                } else {
                                    path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                                }
                            }
                        }
                        .stroke(metricType.displayInfo.color.solidColor, lineWidth: 2)
                        
                        // Data points
                        ForEach(Array(trendData.enumerated()), id: \.offset) { index, data in
                            let xPosition = CGFloat(index) / CGFloat(max(trendData.count - 1, 1)) * geometry.size.width
                            let yPosition = geometry.size.height - (CGFloat((data.value - minValue) / range) * geometry.size.height)
                            
                            Circle()
                                .fill(index == trendData.count - 1 ? metricType.displayInfo.color.solidColor : Color.gray)
                                .frame(width: 8, height: 8)
                                .position(x: xPosition, y: yPosition)
                        }
                    }
                }
                .frame(height: 200)
                
                // Target label
                HStack {
                    Spacer()
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("Target: \(formatTarget(target))")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                // Month labels
                HStack {
                    ForEach(trendData, id: \.month) { data in
                        VStack(spacing: 4) {
                            Text(data.month)
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                            Text(formatValue(data.value))
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private func getTrendData() -> [(month: String, value: Double)] {
        let metrics = metricsManager.getMetrics(for: metricType, months: 6)
        let calendar = Calendar.current
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM"
        
        var data: [(month: String, value: Double)] = []
        let now = Date()
        
        for i in 0..<6 {
            if let date = calendar.date(byAdding: .month, value: -(5 - i), to: now) {
                let monthStr = monthFormatter.string(from: date)
                if let metric = metrics.first(where: { calendar.isDate($0.date, equalTo: date, toGranularity: .month) }) {
                    data.append((month: monthStr, value: metric.value))
                } else if i == 5, let latest = metrics.first {
                    data.append((month: monthStr, value: latest.value))
                }
            }
        }
        
        // Fill with sample data if needed (for demo)
        if data.isEmpty, let latest = metricsManager.getLatestMetric(for: metricType) {
            let target = metricsManager.getTarget(for: metricType)
            let sampleValues = generateSampleData(current: latest.value, target: target, metricType: metricType)
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "MMM"
            let now = Date()
            
            for i in 0..<6 {
                if let date = calendar.date(byAdding: .month, value: -(5 - i), to: now) {
                    data.append((month: monthFormatter.string(from: date), value: sampleValues[i]))
                }
            }
        }
        
        return data
    }
    
    private func generateSampleData(current: Double, target: Double, metricType: MetricType) -> [Double] {
        var values: [Double] = []
        let isDecreasing = current > target
        
        for i in 0..<6 {
            let progress = Double(i) / 5.0
            if isDecreasing {
                // Decreasing trend
                let value = current - (current - target) * progress
                values.append(value)
            } else {
                // Increasing trend
                let value = current - (current - target) * progress
                values.append(value)
            }
        }
        
        return values
    }
    
    private func formatValue(_ value: Double) -> String {
        if metricType == .sleepQuality || metricType == .stressLevel {
            return String(format: "%.1f", value)
        } else if metricType == .lifestyleAdherence || metricType == .dietAdherence {
            return String(format: "%.0f", value)
        } else if metricType == .steps {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.0f", value)
        } else {
            return String(format: "%.0f", value)
        }
    }
    
    private func formatTarget(_ target: Double) -> String {
        if metricType == .sleepQuality || metricType == .stressLevel {
            return String(format: "%.1f", target)
        } else if metricType == .lifestyleAdherence || metricType == .dietAdherence {
            return String(format: "%.0f", target)
        } else if metricType == .steps {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter.string(from: NSNumber(value: target)) ?? String(format: "%.0f", target)
        } else {
            return String(format: "%.0f", target)
        }
    }
}

// MARK: - Analysis Card

struct AnalysisCard: View {
    let metric: HealthMetric
    let metricType: MetricType
    let trend: Double?
    let target: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Analysis")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            
            Text(getAnalysisText())
                .font(.system(size: 14))
                .foregroundColor(.black)
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.9, green: 0.98, blue: 0.9))
        .cornerRadius(12)
    }
    
    private func getAnalysisText() -> String {
        let difference = abs(metric.value - target)
        
        switch metricType {
        case .hba1c:
            if metric.value < 5.7 {
                return "Excellent! You're in the normal range. Keep maintaining your healthy lifestyle!"
            } else if metric.value < 6.5 {
                return "Great progress! You've moved from diabetic to prediabetic range. Keep up the great work! You're \(String(format: "%.1f", difference))% away from your target."
            } else {
                return "You're making progress on your diabetes reversal journey. Focus on consistent lifestyle changes to reach your target."
            }
        case .fastingBloodGlucose:
            if metric.value < 100 {
                return "Excellent! You've reached the healthy fasting glucose range (70-99 mg/dL)."
            } else if metric.value < 126 {
                return "Good progress! You're in the prediabetes range. Continue your healthy habits to reach the normal range."
            } else {
                return "Keep working on your lifestyle changes. Every improvement brings you closer to your target."
            }
        case .postprandialGlucose:
            if metric.value < 140 {
                return "Your post-meal glucose is well controlled, showing excellent meal choices."
            } else if metric.value < 200 {
                return "Your post-meal glucose is improving. Continue making healthy food choices."
            } else {
                return "Focus on meal timing and food choices to improve your post-meal glucose levels."
            }
        case .weight:
            if let trend = trend, trend < 0 {
                return "Lost \(String(format: "%.0f", abs(trend))) lbs! Keep up the great work! You're \(String(format: "%.1f", difference))lbs away from your target."
            } else {
                return "Weight management is crucial for diabetes reversal. Focus on sustainable lifestyle changes."
            }
        case .sleepQuality:
            if metric.value >= 8 {
                return "Excellent sleep quality! This supports better glucose control."
            } else {
                return "Your sleep quality has improved significantly, supporting better glucose control. You're making progress! Just \(String(format: "%.1f", difference))/10 away from your target."
            }
        case .stressLevel:
            if metric.value <= 3 {
                return "Great stress management! Lower stress helps improve insulin sensitivity."
            } else {
                return "Great stress management! Lower stress helps improve insulin sensitivity. Keep up the great work! You're \(String(format: "%.1f", difference))/10 away from your target."
            }
        case .lifestyleAdherence:
            if metric.value >= 90 {
                return "You're consistently following healthy lifestyle habits!"
            } else {
                return "You're consistently following healthy lifestyle habits! You're making progress! Just \(String(format: "%.1f", difference))% away from your target."
            }
        case .dietAdherence:
            if metric.value >= 90 {
                return "Your dietary choices are supporting your reversal journey!"
            } else {
                return "Your dietary choices are supporting your reversal journey! You're making progress! Just \(String(format: "%.1f", difference))% away from your target."
            }
        case .steps:
            if metric.value >= 10000 {
                return "Excellent! You're meeting your daily step goal. Regular movement helps improve insulin sensitivity and supports your diabetes reversal journey!"
            } else {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                let formatted = formatter.string(from: NSNumber(value: difference)) ?? String(format: "%.0f", difference)
                return "You're making great progress with your daily steps! Keep moving to reach your target. You're \(formatted) steps away from your goal."
            }
        }
    }
}

