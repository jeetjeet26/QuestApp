//
//  UserQuestData.swift
//  Questapp
//
//  Created by Jasjit Gill on 6/23/23.
//
import Foundation
class UserQuestData: ObservableObject {
    @Published var completedQuests: Int = 0 {
        didSet {
            saveData()
        }
    }
    
    private let completedQuestsKey = "completedQuests"
    
    init() {
        loadData()
    }
    
    private func loadData() {
        if let savedCompletedQuests = UserDefaults.standard.value(forKey: completedQuestsKey) as? Int {
            completedQuests = savedCompletedQuests
        }
    }
    
    private func saveData() {
        UserDefaults.standard.setValue(completedQuests, forKey: completedQuestsKey)
    }
}
