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
    @Published var ref: DatabaseReference! = Database.database().reference()
    
    func addUser(userName username: String) {
        print("add user called")
        guard let location = user.userLocation else {
            print("location is nil")
            return
        }
        
        let locationDict: [String: Any] = [
            "latitude": location.lat,
            "longitude": location.lng,
            "address": location.address
        ]
        
        self.ref.child("users").child(user.id).setValue(["userid": user.id, "username": username, "userlocation": locationDict])
        
        print("add user success")
    }
    
    func fetchUserInfo(userID: String, completion: @escaping (Bool) -> Void) {
        ref.child("users").child(userID).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                // 유저 존재하면 정보 업데이트
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
                    
                    self.user = User(id: userID, userName: username, userLocation: location)
                }
                completion(true)  // 유저 존재
                print("fetch success")
            } else {
                completion(false) // 유저 없음
            }
        }
    }
    
}
