//
//  RewardScreen.swift
//  Questapp
//
//  Created by Jasjit Gill on 6/23/23.
//
import SwiftUI
struct RewardScreen: View {
    @EnvironmentObject private var userQuestData: UserQuestData // Use UserQuestData instead of RewardUserQuestData
    var body: some View {
        VStack {
            Spacer()
            // Add any additional content here
        }
        .navigationBarTitle(Text("Reward"), displayMode: .inline)
        .padding()
    }
}
