//
//  RewardScreen.swift
//  Questapp
//
//  Created by Jasjit Gill on 6/23/23.
//
import SwiftUI
struct RewardScreen: View {
    @EnvironmentObject private var userQuestData: UserQuestData // Use UserQuestDater instead of RewardUserQuestData
    var body: some View {
        VStack {
            Spacer()
            // Add any additional content here
        }
        .navigationBarTitle(Text("Loot"), displayMode: .inline)
        .padding()
    }
}
