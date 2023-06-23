//
//  QuestTrackerView.swift
//  Questapp
//
//  Created by Jasjit Gill on 6/23/23.
//
import SwiftUI

struct QuestTrackerView: View {
    @EnvironmentObject var userQuestData: UserQuestData
    
    var body: some View {
        VStack {
            Text("Quest Tracker")
                .font(.title)
                .padding()

            Text("Completed Quests: \(userQuestData.completedQuests)")
                .font(.title)
                .padding()

            Spacer()
        }
    }
}
