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
        KeychainHelper.save(platform.rawValue, forKey: KeychainHelper.Key.loginPlatform)
    }
    
    func getLoginPlatform() -> LoginPlatform? {
        guard let value = UserDefaults.standard.string(forKey: "loginPlatform") else {
            return nil
        }
        return LoginPlatform(rawValue: value)
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "loginPlatform")
        KeychainHelper.delete(forKey: KeychainHelper.Key.userId)
        KeychainHelper.delete(forKey: KeychainHelper.Key.fcmToken)
        state = .login
    }
}

