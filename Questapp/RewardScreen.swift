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
            Text("Reward Screen")
                .font(.title)
                .padding()
            Text("Completed Quests: \(userQuestData.completedQuests)")
                .font(.title)
                .padding()
        }
    }
}
