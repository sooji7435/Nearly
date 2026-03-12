//
//  SwiftUIView.swift
//  Nearly
//
//  Created by 박윤수 on 1/3/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var appState: AppStateViewModel
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        VStack {
            Spacer()
            
        // MARK: - App Logo
            VStack {
                Image("AppLogo")
                    .font(.system(size: 60))
                    .foregroundStyle(.primary)
            }
            Spacer()
            
            // MARK: - Naver login button
            Button(action: {authViewModel.googleLogIn()}) {
                Image("google_login")
            }
            
            // MARK: - Kakao login button
            Button ( action: { authViewModel.kakaoLogin() }) {
                Image("kakao_login")
                    .resizable()
                    .frame(width: 320, height: 50)
            }
            
            // MARK: - Naver login button
            Button (action: {authViewModel.naverLogin()}) {
                Image("naver_login")
                    .resizable()
                    .frame(width: 320, height: 50)
            }
                        
            Spacer()
                .frame(height: 60)
        }
        .onChange(of: authViewModel.signState) {
            appState.state = .createProfile
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationViewModel())
        .environmentObject(AppStateViewModel())
        .environmentObject(UserManager())
}
