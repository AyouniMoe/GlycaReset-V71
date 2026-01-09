//
//  HbA1cInputView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct HbA1cManualInputView: View {
    @ObservedObject var metricsManager: HealthMetricsManager
    @Environment(\.dismiss) var dismiss
    
    @State private var hba1cValue: String = ""
    @State private var selectedDate: Date = Date()
    @State private var showDatePicker = false
    @State private var errorMessage: String?
    @FocusState private var isFocused: Bool
    
    private var maxDate: Date {
        return Date() // Today is the maximum date
    }
    
    private var isValueValid: Bool {
        guard let value = Double(hba1cValue) else { return false }
        return value >= 0 && value <= 20 // Reasonable range for HbA1c
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.95, green: 0.96, blue: 0.98)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.2))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "drop.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 1.0))
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        
                        // Title
                        Text("Enter HbA1c Result")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                        
                        Text("Add your HbA1c test result to track your progress over time")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        // HbA1c Value Input
                        VStack(alignment: .leading, spacing: 12) {
                            Text("HbA1c Value")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            HStack(spacing: 8) {
                                TextField("0.0", text: $hba1cValue)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(isValueValid ? Color(red: 0.2, green: 0.6, blue: 1.0) : Color.gray.opacity(0.3), lineWidth: 2)
                                    )
                                    .cornerRadius(12)
                                    .focused($isFocused)
                                
                                Text("%")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.trailing, 8)
                            }
                            
                            if !hba1cValue.isEmpty && !isValueValid {
                                Text("Please enter a valid HbA1c value (0-20%)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Date Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Test Date")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Button(action: {
                                showDatePicker.toggle()
                            }) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color(red: 0.2, green: 0.6, blue: 1.0))
                                    
                                    Text(formatDate(selectedDate))
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                .padding(16)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .cornerRadius(12)
                            }
                            
                            if showDatePicker {
                                DatePicker(
                                    "",
                                    selection: $selectedDate,
                                    in: ...maxDate,
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.graphical)
                                .accentColor(Color(red: 0.2, green: 0.6, blue: 1.0))
                                .colorScheme(.light)
                                .padding(16)
                                .background(Color(red: 0.98, green: 0.98, blue: 0.99))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Reference Ranges
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Reference Ranges")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ReferenceRangeRow(range: "< 5.7%", label: "Normal", color: Color(red: 0.2, green: 0.8, blue: 0.4))
                                ReferenceRangeRow(range: "5.7 - 6.4%", label: "Prediabetes", color: Color(red: 1.0, green: 0.6, blue: 0.2))
                                ReferenceRangeRow(range: "≥ 6.5%", label: "Diabetes", color: Color.red)
                            }
                        }
                        .padding(16)
                        .background(Color(red: 0.9, green: 0.95, blue: 1.0))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        
                        // Error Message
                        if let error = errorMessage {
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .padding(.horizontal, 20)
                        }
                        
                        // Save Button
                        Button(action: {
                            saveHbA1c()
                        }) {
                            Text("SAVE RESULT")
                                .font(.system(size: 16, weight: .bold))
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
                        .disabled(!isValueValid)
                        .opacity(isValueValid ? 1.0 : 0.5)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Add HbA1c")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.black)
                }
            }
            .onTapGesture {
                isFocused = false
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
    
    private func saveHbA1c() {
        guard let value = Double(hba1cValue) else {
            errorMessage = "Please enter a valid number"
            return
        }
        
        guard value >= 0 && value <= 20 else {
            errorMessage = "HbA1c value must be between 0 and 20%"
            return
        }
        
        // Check if a metric already exists for this date
        if metricsManager.hasMetric(for: .hba1c, date: selectedDate) {
            errorMessage = "An HbA1c result already exists for this date. Please select a different date."
            return
        }
        
        // Create and save the metric
        let metric = HealthMetric(
            type: .hba1c,
            value: value,
            date: selectedDate
        )
        
        metricsManager.addMetric(metric)
        dismiss()
    }
}

struct ReferenceRangeRow: View {
    let range: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(range)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
    }
}

