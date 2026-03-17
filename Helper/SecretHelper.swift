//
//  SecretHelper.swift
//  Nearly
//
//  Created by 박윤수 on 3/17/26.
//
import Foundation

struct SecretHelper {
    
    static func value(for key: String) -> String {
        guard let val = Bundle.main.infoDictionary?[key] as? String, !val.isEmpty else {
            assertionFailure("⚠️ SecretHelper: '\(key)' 키가 Info.plist에 없습니다. xcconfig 연결을 확인하세요.")
            return ""
        }
        return val
    }
}

// MARK: - Key 상수
extension SecretHelper {
    enum Key {
        static let kakaoAppKey       = "KAKAO_APP_KEY"
        static let naverClientId     = "NAVER_CLIENT_ID"
        static let naverClientSecret = "NAVER_CLIENT_SECRET"
    }
}
