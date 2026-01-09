//
//  RemissionView.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import SwiftUI

struct RemissionView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Remission Status")
                .font(.title)
                .bold()
            
            Text("Show your remission progress here.")
        }
        .padding()
        .navigationTitle("Remission Status")
        .navigationBarTitleDisplayMode(.inline)
    }
}
