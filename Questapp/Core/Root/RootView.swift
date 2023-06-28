//
//  RootView.swift
//  Questapp
//
//  Created by Jasjit Gill on 6/28/23.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct RootView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var userQuestData: UserQuestData  // add this line

    var body: some View {
        Group {
            if viewModel.userSession != nil {
                ContentView()
                    .environmentObject(userQuestData)  // provide userQuestData here
            } else {
                LoginView()
            }
        }
    }
}
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
