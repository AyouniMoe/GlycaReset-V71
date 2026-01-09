//
//  AddHabitView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct AddHabitView: View {
    let habit: Habit?
    @ObservedObject var habitsManager: HabitsManager
    let onSave: (Habit) -> Void
    let onCancel: () -> Void
    
    @State private var selectedType: HabitType = .lifestyle
    @State private var title: String = ""
    @State private var description: String = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case title, description
    }
    
    var isEditing: Bool {
        habit != nil
    }
    
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.95, green: 0.96, blue: 0.98)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Type Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Habit Type")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            HStack(spacing: 12) {
                                TypeButton(
                                    type: .lifestyle,
                                    isSelected: selectedType == .lifestyle
                                ) {
                                    selectedType = .lifestyle
                                }
                                
                                TypeButton(
                                    type: .diet,
                                    isSelected: selectedType == .diet
                                ) {
                                    selectedType = .diet
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Title Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            
                            TextField("e.g., Morning Walk", text: $title)
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .cornerRadius(12)
                                .focused($focusedField, equals: .title)
                        }
                        .padding(.horizontal, 20)
                        
                        // Description Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            
                            TextEditor(text: $description)
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .frame(minHeight: 120)
                                .padding(8)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .cornerRadius(12)
                                .focused($focusedField, equals: .description)
                        }
                        .padding(.horizontal, 20)
                        
                        // Tips
                        VStack(alignment: .leading, spacing: 8) {
                            Text("💡 Tips")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Text("• Be specific about what you want to achieve\n• Include timing or frequency when relevant\n• Keep it realistic and achievable")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .lineSpacing(4)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.9, green: 0.98, blue: 0.9))
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Habit" : "New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .foregroundColor(.black)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Save" : "Create") {
                        let newHabit = Habit(
                            id: habit?.id ?? UUID(),
                            title: title.trimmingCharacters(in: .whitespaces),
                            description: description.trimmingCharacters(in: .whitespaces),
                            type: selectedType,
                            simplifiedSteps: habit?.simplifiedSteps,
                            isPublished: habit?.isPublished ?? false,
                            createdAt: habit?.createdAt ?? Date(),
                            updatedAt: Date()
                        )
                        onSave(newHabit)
                    }
                    .foregroundColor(isValid ? Color(red: 0.2, green: 0.6, blue: 1.0) : .gray)
                    .disabled(!isValid)
                }
            }
        }
        .onAppear {
            if let habit = habit {
                selectedType = habit.type
                title = habit.title
                description = habit.description
            }
        }
    }
}

struct TypeButton: View {
    let type: HabitType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.system(size: 18))
                
                Text(type.displayName)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : type.color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? type.color : type.color.opacity(0.1))
            )
        }
    }
}

