//
//  AppStateViewModel.swift
//  Nearly
//
//  Created by 박윤수 on 3/6/26.
//

import Foundation
import Combine

enum AppState {
    case login
    case createProfile
    case main
}

enum LoginPlatform: String {
    case google
    case kakao
    case naver
}

class AppStateViewModel: ObservableObject {
    @Published var state: AppState = .login
    
    func checkLogin() {
        guard let _ = getLoginPlatform() else {
            state = .login
            return
        }
        state = .main
    }
    
    func setLoginPlatform(_ platform: LoginPlatform) {
        // [FIX] 저장과 읽기 모두 Keychain으로 통일
        KeychainHelper.save(platform.rawValue, forKey: KeychainHelper.Key.loginPlatform)
    }
    
    func getLoginPlatform() -> LoginPlatform? {
        // [FIX] UserDefaults 대신 Keychain에서 읽도록 수정
        guard let value = KeychainHelper.load(forKey: KeychainHelper.Key.loginPlatform) else {
            return nil
        }
        return LoginPlatform(rawValue: value)
    }
    
    func logout() {
        // [FIX] UserDefaults 삭제 → Keychain 삭제로 변경
        KeychainHelper.delete(forKey: KeychainHelper.Key.loginPlatform)
        KeychainHelper.delete(forKey: KeychainHelper.Key.userId)
        KeychainHelper.delete(forKey: KeychainHelper.Key.fcmToken)
        state = .login
    }
}
