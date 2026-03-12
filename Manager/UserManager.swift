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
    @Published var user: User?
    @Published var ref: DatabaseReference! = Database.database().reference()
    
    
    func updateLocation(_ location: UserLocation) {
        user?.userLocation = location
    }
    
    func saveProfile(_ userName: String) {
        user?.userName = userName
    }
    
    func addUser() {
        guard let user = user,
              let location = user.userLocation else { return }
        
        let locationDict: [String: Any] = [
            "latitude": location.lat,
            "longitude": location.lng,
            "address": location.address
        ]
        
        self.ref.child("users").child(user.id).setValue(["userid": user.id,"username": user.userName ?? "", "userlocation": locationDict])
        
        print("add user success")
    }
    
    func fetchUserInfo(platformID: String) {
        print("fetchUserInfo called")

        ref.child("users").child(platformID).observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [String: AnyObject] else { print("snapshot is not dictionary")
                return }
            
            let username = value["username"] as? String ?? ""
            var location = UserLocation(lat: 0, lng: 0, address: "")
            
            if let locationData = value["userlocation"] as? [String: Any] {
                let lat = locationData["latitude"] as? Double ?? 0
                let lon = locationData["longitude"] as? Double ?? 0
                let address = locationData["address"] as? String ?? ""
                
                location = UserLocation(lat: lat, lng: lon, address: address)
            }
            
            self.user = User(
                id: platformID,
                userName: username,
                userLocation: location
            )
        }
        )
        if let  user = self.user {
            print(user)

        }
    }
}
