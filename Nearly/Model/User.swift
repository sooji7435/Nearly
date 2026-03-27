//
//  UserDataViewModel.swift
//  Nearly
//
//  Created by 박윤수 on 1/7/26.
//

import Foundation
import PhotosUI

struct User: Identifiable {
    var id: String
    var userName: String?
    var userLocation: UserLocation?
    var fcmToken: String?
}
