//
//  QuestappApp.swift
//  Questapp
//
//  Created by Jasjit Gill on 6/22/23.
//
import SwiftUI
import FirebaseCore
import Firebase
import Foundation
import FirebaseAuth


@main
struct QuestappApp: App {
    @StateObject private var userQuestData = UserQuestData()
    @StateObject private var rewardUserQuestData = UserQuestData()
    @StateObject var viewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(userQuestData)
                .environmentObject(rewardUserQuestData)
                .environmentObject(viewModel)
        }
    }
}

