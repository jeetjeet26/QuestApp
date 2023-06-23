//
//  QuestappApp.swift
//  Questapp
//
//  Created by Jasjit Gill on 6/22/23.
//
import SwiftUI

@main
struct QuestappApp: App {
    @StateObject private var userQuestData = UserQuestData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userQuestData)
        }
    }
}