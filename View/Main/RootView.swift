//
//  RootView.swift
//  Nearly
//
//  Created by 박윤수 on 3/6/26.
//
import SwiftUI
import FirebaseAuth

struct RootView: View {
    @EnvironmentObject var auth: AuthenticationViewModel
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var appState: AppStateViewModel
    
    var body: some View {
        NavigationStack {
            if auth.signState == .signOut {
                LoginView()
            }
            else if auth.signState == .signIn && appState.isOnboardingComplete{
                MainView()
                
            }
            else {
                switch appState.state {

                case .createProfile:
                    ProfileView()
                case .main:
                    MainView()
                }
            }
        }
        .onAppear {
            userManager.fetchUserInfo(platformID: )
        }

    }
}


#Preview {
    RootView()
}
