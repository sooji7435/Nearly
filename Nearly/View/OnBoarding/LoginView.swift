//
//  LoginView.swift
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
            Button { handleLogin(perform: authViewModel.googleLogIn, platform: .google) } label: {
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
            Button { handleLogin(perform: authViewModel.kakaoLogin, platform: .kakao) } label: {
                Image("kakao_login")
                    .resizable()
                    .frame(width: 320, height: 50)
            }

            // MARK: - Naver login button
            Button { handleLogin(perform: authViewModel.naverLogin, platform: .naver) } label: {
                Image("naver_login")
                    .resizable()
                    .frame(width: 320, height: 50)
            }

            Spacer()
                .frame(height: 60)
        }
    }

    private func handleLogin(perform login: @escaping (@escaping (String) -> Void) -> Void, platform: LoginPlatform) {
        login { userID in
            KeychainHelper.save(userID, forKey: KeychainHelper.Key.userId)
            userManager.saveToken()
            userManager.user.id = userID
            appStateViewModel.setLoginPlatform(platform)
            userManager.fetchUserInfo(userID: userID) { exists in
                if exists {
                    userManager.updateFcmToken()
                    appStateViewModel.state = .main
                } else {
                    appStateViewModel.state = .createProfile
                }
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationViewModel())
}
