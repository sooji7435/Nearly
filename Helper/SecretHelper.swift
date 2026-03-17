//
//  SecretHelper.swift
//  Nearly
//
//  Created by 박윤수 on 3/17/26.
//

import Foundation

func secret(_ key: String) -> String {
    Bundle.main.infoDictionary?[key] as? String ?? ""
}
