//
//  RootView.swift
//  Nearly
//
//  Created by 박윤수 on 3/6/26.
//
import SwiftUI
import FirebaseAuth

struct RootView: View {
    @EnvironmentObject var appStateViewModel: AppStateViewModel
    
    
    var body: some View {
        NavigationStack {
                switch appStateViewModel.state {

                case .login:
                    LoginView()
                    
                case .createProfile:
                    ProfileView()
                    
                case .main:
                    MainView()
                }
            }
        }
    }

#Preview {
    RootView()
        .environmentObject(UserManager())
}
