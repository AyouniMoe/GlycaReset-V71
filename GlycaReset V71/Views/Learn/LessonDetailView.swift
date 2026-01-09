//
//  LessonDetailView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    let moduleId: UUID
    @ObservedObject var learningManager: LearningManager
    @Environment(\.dismiss) var dismiss
    
    @State private var showGamifiedView = true
    
    var body: some View {
        if showGamifiedView {
            GamifiedLessonView(lesson: lesson, moduleId: moduleId, learningManager: learningManager)
        } else {
            // Fallback to simple view if needed
            NavigationView {
                ZStack {
                    Color(red: 0.95, green: 0.96, blue: 0.98)
                        .ignoresSafeArea()
                    
                    Text("Loading...")
                }
            }
        }
    }
}

// ModuleTestView is now in Views/Learn/ModuleTestView.swift

