//
//  KeyChainHelper.swift
//  Nearly
//
//  Created by 박윤수 on 3/17/26.
//

import Foundation
import Security

struct KeychainHelper {
    
    static func save(_ value: String, forKey key: String) {
        let data = Data(value.utf8)
        
        // 기존 항목 삭제 후 저장
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    static func load(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        
        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    static func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}

extension KeychainHelper {
    enum Key {
        static let fcmToken = "fcmToken"
        static let userId   = "userId"
    }
}
