//
//  AuthenticationViewModel.swift
//  Nearly
//
//  Created by 박윤수 on 1/5/26.
//

import SwiftUI
import Combine
import KakaoSDKUser
import NidThirdPartyLogin
import GoogleSignIn

enum SignState {
    case signIn
    case signOut
}

class AuthenticationViewModel: ObservableObject {
    @Published var userManager: UserManager = UserManager()
    @Published var signState: SignState = .signOut
    @Published var currentUser: User?
    
    // MARK: - Kakao Login
    func kakaoLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { _, error in
                if let error = error {
                    print("KakaoTalk Login Error:", error.localizedDescription)
                    return
                }
                self.loadKakaoUserInfo()
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { _, error in
                if let error = error {
                    print("Kakao Account Login Error:", error.localizedDescription)
                    return
                }
                self.loadKakaoUserInfo()
            }
        }
    }
    
    private func loadKakaoUserInfo() {
        UserApi.shared.me { userId, error in
            if let error = error {
                print("Kakao User Info Error:", error.localizedDescription)
                return
            }
            
            guard let id = userId else { return }
               
            DispatchQueue.main.async {
                self.userManager.user?.id = "kakao_\(id)"
                self.userManager.fetchUserInfo(platformID: "kakao_\(id)")
                self.signState = .signIn
            }
            
        }
    }

    // MARK: - Google Login
    func googleLogIn() {
        let clientID = "256669622710-kj730j8ovfqri1urcll636mvg5gojj2n.apps.googleusercontent.com"

        // rootViewController 가져오기
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            if let error = error {
                print("Sign-in error: \(error)")
                return
            }
            
            guard let userID = result?.user.userID else { return }
            
            DispatchQueue.main.async {
                self.userManager.user?.id = "google_\(userID)"
                self.signState = .signIn
            }
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }
    
    // MARK: - Naver Login

    
    func naverLogin() {
        NidOAuth.shared.requestLogin{ result in
            switch result {
                
            case .success(let loginResult):
                print("Access Token: ", loginResult.accessToken.tokenString)
                self.fetchUserId(accessToken: loginResult.accessToken.tokenString)
                
                
            case .failure(let error):
                print("Error: ", error.localizedDescription)
            }
        }
    }
    
    private func fetchUserId(accessToken: String) {
        let url = URL(string: "https://openapi.naver.com/v1/nid/me")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let response = json["response"] as? [String: Any],
                  let id = response["id"] as? String else {
                return
            }
            
            DispatchQueue.main.async {
                self.userManager.user?.id = "naver_\(id)"
                self.userManager.fetchUserInfo(platformID: "naver_\(id)")
                self.signState = .signIn
                print("네이버 사용자 ID:", id)
            }
        }.resume()
    }
    
}
