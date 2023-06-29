//
//  UserQuestData.swift
//  Questapp
//
//  Created by Jasjit Gill on 6/23/23.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth
import Firebase

class UserQuestData: ObservableObject {
    @Published var completedQuests: Int = 0 {
        didSet {
            updateQuestsInFirebase()
        }
    }
    
    private var listener: ListenerRegistration?
    private let db = Firestore.firestore()
    
    init() {
        loadData()
    }
    
    deinit {
        // Remember to remove the listener when the object is deallocated
        listener?.remove()
    }
    
    private func loadData() {
        // Check if the Firebase authentication is complete
        _ = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                // Fetch the user data once the user ID is available
                let docRef = self.db.collection("users").document(user.uid)

                self.listener = docRef.addSnapshotListener { documentSnapshot, error in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    guard let data = document.data() else {
                        print("Document data was empty.")
                        return
                    }
                    self.completedQuests = data["completedQuests"] as? Int ?? 0
                }
            }
        }
    }

    
    private func updateQuestsInFirebase() {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let docRef = db.collection("users").document(userID)

        docRef.setData(["completedQuests": self.completedQuests], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
}
