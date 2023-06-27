//
//  WelcomeView.swift
//  Questapp
//
//  Created by Jasjit Gill on 6/26/23.
//
import SwiftUI
import Firebase
import Foundation
import Combine

struct WelcomeView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoggedIn = false // Added property to track login status
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to QuestApp!")
                    .font(.title)
                    .padding()
                
                Text("Get ready to embark on exciting quests and explore the world around you.")
                    .multilineTextAlignment(.center)
                    .padding()
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .textContentType(.emailAddress) // Add this line for email field
                    .keyboardType(.emailAddress) // Set the keyboard type to email address
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .textContentType(.password) // Add this line for password field
                
                Button(action: {
                    login()
                }) {
                    Text("Login")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                Button(action: {
                    signUp()
                }) {
                    Text("Sign Up")
                        .font(.title)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                NavigationLink(
                    destination: ContentView(),
                    isActive: $isLoggedIn
                ) {
                    EmptyView()
                }
                .hidden()
                .onReceive(Just(isLoggedIn)) { value in
                    if value {
                        showAlert = false
                    }
                }
            }
            .navigationBarTitle("Welcome")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                showAlert = true
                alertMessage = error.localizedDescription
            } else {
                // Successful signup
                showAlert = true
                alertMessage = "Signup successful!"
                isLoggedIn = true // Set isLoggedIn to true upon successful signup
            }
        }
    }
    
    private func login() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                showAlert = true
                alertMessage = error.localizedDescription
            } else {
                // Successful login
                showAlert = true
                alertMessage = "Login successful!"
                isLoggedIn = true // Set isLoggedIn to true upon successful login
            }
        }
    }
}
