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

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct QuestappApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var userQuestData = UserQuestData()
    @StateObject private var rewardUserQuestData = UserQuestData()
    @StateObject var viewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userQuestData)
                .environmentObject(rewardUserQuestData)
                .environmentObject(viewModel)
        }
    }
}

