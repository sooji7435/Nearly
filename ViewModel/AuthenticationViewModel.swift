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
    @Published var signState: SignState = .signOut
    
    // MARK: - Kakao Login
    func kakaoLogin(completion: @escaping (String) -> Void) {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { _, error in
                if let error = error {
                    print(error)
                    return
                }
                self.loadKakaoUserInfo(completion: completion)
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { _, error in
                if let error = error {
                    print(error)
                    return
                }
                self.loadKakaoUserInfo(completion: completion)
            }
        }
    }
    
    private func loadKakaoUserInfo(completion: @escaping (String) -> Void) {
        UserApi.shared.me { user, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let id = user?.id else { return }
               
            DispatchQueue.main.async {
                self.signState = .signIn
                completion("kakao_\(id)")
            }
        }
    }

    // MARK: - Google Login
    func googleLogIn(completion: @escaping (String) -> Void) {
        // rootViewController 가져오기
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let userID = result?.user.userID else { return }
            
            DispatchQueue.main.async {
                self.signState = .signIn
                completion("google_\(userID)")
            }
        }
    }

    // MARK: - Naver Login
    func naverLogin(completion: @escaping (String) -> Void) {
        NidOAuth.shared.requestLogin{ result in
            switch result {
                
            case .success(let loginResult):
                self.fetchUserId(accessToken: loginResult.accessToken.tokenString, completion: completion)
    
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func fetchUserId(accessToken: String, completion: @escaping (String) -> Void) {
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
                self.signState = .signIn
                completion("naver_\(id)")
            }
        }.resume()
    }
    
    func signOut(platform: LoginPlatform) {
        switch platform {
        case .google:
            GIDSignIn.sharedInstance.signOut()
        case .kakao:
            UserApi.shared.logout { _ in }
        case .naver:
            NidOAuth.shared.logout()
        }
        signState = .signOut
    }
}
