//
//  HbA1cTrendGraphView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct HbA1cTrendGraphView: View {
    let metrics: [HealthMetric]
    let target: Double
    
    private var sortedMetrics: [HealthMetric] {
        metrics.sorted { $0.date < $1.date }
    }
    
    private var minValue: Double {
        let minMetric = sortedMetrics.map { $0.value }.min() ?? 0
        return min(minMetric - 0.5, target - 1.0)
    }
    
    private var maxValue: Double {
        let maxMetric = sortedMetrics.map { $0.value }.max() ?? 10
        return max(maxMetric + 0.5, target + 1.0)
    }
    
    private var valueRange: Double {
        return maxValue - minValue
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title
            Text("6-Year Trend")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            
            if sortedMetrics.isEmpty {
                EmptyTrendView()
            } else {
                // Graph
                GeometryReader { geometry in
                    ZStack(alignment: .bottomLeading) {
                        // Grid lines
                        GridLinesView(
                            minValue: minValue,
                            maxValue: maxValue,
                            target: target,
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                        
                        // Data line and points
                        DataLineView(
                            metrics: sortedMetrics,
                            minValue: minValue,
                            maxValue: maxValue,
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                    }
                }
                .frame(height: 200)
                
                // X-axis labels
                XAxisLabelsView(metrics: sortedMetrics)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Grid Lines View

struct GridLinesView: View {
    let minValue: Double
    let maxValue: Double
    let target: Double
    let width: CGFloat
    let height: CGFloat
    
    private var valueRange: Double {
        return maxValue - minValue
    }
    
    var body: some View {
        ZStack {
            // Horizontal grid lines
            ForEach(0..<5) { index in
                let value = minValue + (Double(index) / 4.0) * valueRange
                let yPosition = height - (CGFloat((value - minValue) / valueRange) * height)
                
                if index < 4 {
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: yPosition))
                        path.addLine(to: CGPoint(x: width, y: yPosition))
                    }
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                }
            }
            
            // Target line (6.5% or target value)
            let targetYPosition = height - (CGFloat((target - minValue) / valueRange) * height)
            Path { path in
                path.move(to: CGPoint(x: 0, y: targetYPosition))
                path.addLine(to: CGPoint(x: width, y: targetYPosition))
            }
            .stroke(Color(red: 1.0, green: 0.6, blue: 0.2), style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
            
            // Y-axis labels
            ForEach(0..<5) { index in
                let value = minValue + (Double(index) / 4.0) * valueRange
                let yPosition = height - (CGFloat((value - minValue) / valueRange) * height)
                
                Text(String(format: "%.1f", value) + "%")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .offset(x: -30, y: yPosition - 8)
            }
        }
    }
}

// MARK: - Data Line View

struct DataLineView: View {
    let metrics: [HealthMetric]
    let minValue: Double
    let maxValue: Double
    let width: CGFloat
    let height: CGFloat
    
    private var valueRange: Double {
        return maxValue - minValue
    }
    
    var body: some View {
        ZStack {
            // Gradient fill area
            if metrics.count > 1 {
                Path { path in
                    let step = width / CGFloat(max(1, metrics.count - 1))
                    
                    path.move(to: CGPoint(x: 0, y: height))
                    
                    for (index, metric) in metrics.enumerated() {
                        let xPosition = CGFloat(index) * step
                        let yPosition = height - (CGFloat((metric.value - minValue) / valueRange) * height)
                        path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                    }
                    
                    if let last = metrics.last {
                        let lastX = CGFloat(metrics.count - 1) * (width / CGFloat(max(1, metrics.count - 1)))
                        path.addLine(to: CGPoint(x: lastX, y: height))
                    }
                    
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.3),
                            Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.1)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            
            // Data line
            if metrics.count > 1 {
                Path { path in
                    let step = width / CGFloat(max(1, metrics.count - 1))
                    
                    for (index, metric) in metrics.enumerated() {
                        let xPosition = CGFloat(index) * step
                        let yPosition = height - (CGFloat((metric.value - minValue) / valueRange) * height)
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: xPosition, y: yPosition))
                        } else {
                            path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                        }
                    }
                }
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.2, green: 0.6, blue: 1.0),
                            Color(red: 0.4, green: 0.7, blue: 1.0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                )
            }
            
            // Data points
            ForEach(Array(metrics.enumerated()), id: \.element.id) { index, metric in
                let step = width / CGFloat(max(1, metrics.count - 1))
                let xPosition = CGFloat(index) * step
                let yPosition = height - (CGFloat((metric.value - minValue) / valueRange) * height)
                
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(Color(red: 0.2, green: 0.6, blue: 1.0))
                        .frame(width: 16, height: 16)
                        .blur(radius: 4)
                        .opacity(0.6)
                    
                    // Main point
                    Circle()
                        .fill(Color.white)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.2, green: 0.6, blue: 1.0),
                                            Color(red: 0.4, green: 0.7, blue: 1.0)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                        )
                }
                .offset(x: xPosition - 6, y: yPosition - 6)
            }
        }
    }
}

// MARK: - X-Axis Labels View

struct XAxisLabelsView: View {
    let metrics: [HealthMetric]
    
    private var sortedMetrics: [HealthMetric] {
        metrics.sorted { $0.date < $1.date }
    }
    
    private var displayedIndices: [Int] {
        let count = sortedMetrics.count
        guard count > 0 else { return [] }
        
        if count <= 6 {
            return Array(0..<count)
        } else if count <= 12 {
            // Show first, last, and every other one
            var indices: [Int] = [0]
            for i in stride(from: 2, to: count - 1, by: 2) {
                indices.append(i)
            }
            indices.append(count - 1)
            return indices
        } else {
            // Show first, last, and evenly distributed
            var indices: [Int] = [0]
            let step = max(1, count / 6)
            for i in stride(from: step, to: count - 1, by: step) {
                indices.append(i)
            }
            indices.append(count - 1)
            return indices
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<sortedMetrics.count, id: \.self) { index in
                if displayedIndices.contains(index) {
                    Text(formatDateShort(sortedMetrics[index].date))
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                } else {
                    Spacer()
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.top, 8)
    }
    
    private func formatDateShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
}

// MARK: - Empty Trend View

struct EmptyTrendView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No data yet")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.gray)
            
            Text("Add your first HbA1c result to see your trend")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
}

