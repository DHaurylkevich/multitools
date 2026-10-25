//
//  ContentView.swift
//  multitools
//
//  Created by Mac on 24/10/2026.
//

import SwiftUI

struct ContentView: View {
    var dispatcher: ActionDispatcher
    @State var result = "Choose the action"

    
    var body: some View {
        VStack(alignment: .leading, spacing: 16){
            
            Text("Multitools")
                .font(.title2)
            
            Text(result)
                .font(.title3)
            
            Button(action: {
                result = dispatcher.execute(.screenCapture)
            }){
                Label("Capture screen", systemImage: "viewfinder")
            }
            
            Button(action: {
                result = "Translate text"
            }){
                Label("Translate text", systemImage: "character.book.closed")
            }
            
            Button(action: {
                result = "Voice input"
            }) {
                Label("Voice input", systemImage: "waveform")
            }
        }
        .padding(24)
        .frame(width: 280)
    }
}
