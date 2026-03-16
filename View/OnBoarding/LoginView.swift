//
//  SwiftUIView.swift
//  Nearly
//
//  Created by 박윤수 on 1/3/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var appStateViewModel: AppStateViewModel
    
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
            
            // MARK: - Google login button
            Button(action: { authViewModel.googleLogIn { userID in
                userManager.user.id = userID
                appStateViewModel.setLoginPlatform(.google)
                userManager.fetchUserInfo(userID: userManager.user.id) { exists in
                    if exists {
                        appStateViewModel.state = .main
                    } else {
                        appStateViewModel.state = .createProfile
                    }
                    
                }
            } }) {
                HStack(spacing: -40) {
                    Image("google_login")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding()
                    
                    Text("Sign in with Google")
                        .frame(width: 307, height: 50)
                        .foregroundStyle(Color.black)
                        .font(.system(size: 15))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray, lineWidth: 0.5)
                )
            }
            
            // MARK: - Kakao login button
            Button ( action: { authViewModel.kakaoLogin { userID in
                userManager.user.id = userID
                appStateViewModel.setLoginPlatform(.kakao)
                userManager.fetchUserInfo(userID: userManager.user.id) { exists in
                    if exists {
                        appStateViewModel.state = .main
                    } else {
                        appStateViewModel.state = .createProfile
                    }
                }
            } }) {
                Image("kakao_login")
                    .resizable()
                    .frame(width: 320, height: 50)
            }
            
            // MARK: - Naver login button
            Button (action: { authViewModel.naverLogin { userID in
                userManager.user.id = userID
                appStateViewModel.setLoginPlatform(.naver)
                userManager.fetchUserInfo(userID: userManager.user.id) { exists in
                    if exists {
                        appStateViewModel.state = .main
                    } else {
                        appStateViewModel.state = .createProfile
                    }
                }
            } }) {
                Image("naver_login")
                    .resizable()
                    .frame(width: 320, height: 50)
            }
            
            Spacer()
                .frame(height: 60)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationViewModel())
}
