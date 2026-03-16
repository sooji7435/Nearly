//
//  UserManager.swift
//  Nearly
//
//  Created by 박윤수 on 3/9/26.
//

import Foundation
import Combine
import FirebaseDatabase

class UserManager: ObservableObject {
    @Published var user: User = User(id: "")
    let ref: DatabaseReference! = Database.database().reference()
    
    func addUser(userName username: String) {
        print("add user called")
        guard let location = user.userLocation,
              let token = user.fcmToken else { print("token is nil")
                  return }
        
        let locationDict: [String: Any] = [
            "latitude": location.lat,
            "longitude": location.lng,
            "address": location.address
        ]
        
        self.ref.child("users").child(user.id).setValue(["userid": user.id, "username": username, "userlocation": locationDict, "fcmToken": token])
        print("add user success")
    }
    
    func fetchUserInfo(userID: String, completion: @escaping (Bool) -> Void) {
        print("user fetch start")
        ref.child("users").child(userID).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                if let value = snapshot.value as? [String: AnyObject] {
                    let username = value["username"] as? String ?? ""
                    var location = UserLocation(lat: 0, lng: 0, address: "")
                    
                    if let locationData = value["userlocation"] as? [String: Any] {
                        location = UserLocation(
                            lat: locationData["latitude"] as? Double ?? 0,
                            lng: locationData["longitude"] as? Double ?? 0,
                            address: locationData["address"] as? String ?? ""
                        )
                    }
                    let token = value["fcmToken"] as? String ?? ""
                    self.user = User(id: userID, userName: username, userLocation: location, fcmToken: token)
                }
                completion(true)
                print("user fetch success: \(userID)")
            } else {
                completion(false)
            }
        }
    }
    
    // userId UserDefaults에 저장
    func saveUserId(_ userId: String) {
        UserDefaults.standard.set(userId, forKey: "userId")
    }
    
    // FCM 토큰 저장
    func saveToken() {
        let token = UserDefaults.standard.string(forKey: "fcmToken")
        print("UserDefaults에서 꺼낸 토큰: \(token ?? "nil")")
        guard let token = token else { return }
        self.user.fcmToken = token
    }
    
    // 기존 유저 FCM 토큰 DB 업데이트
    func updateFcmToken() {
        guard let token = user.fcmToken else { return }
        ref.child("users").child(user.id).child("fcmToken").setValue(token)
    }
}
