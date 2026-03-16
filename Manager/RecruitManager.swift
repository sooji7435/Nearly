//
//  RecruitManager.swift
//  Nearly
//
//  Created by 박윤수 on 3/12/26.
//

import Foundation
import Combine
import FirebaseDatabase
import CoreLocation

class RecruitManager: ObservableObject {
    @Published var recruit: Recruit = Recruit(postId: "", authorId: "", title: "", contents: "", time: 0, meetingLocation: CLLocationCoordinate2D(latitude: 0, longitude: 0), route: [] )
    @Published var recruits: [Recruit] = []
    let ref: DatabaseReference! = Database.database().reference()
    
    func addRecruit(authorId: String, title: String, content: String, time: Date) {
        
        print("call addRecruit")
        
        let postId = UUID().uuidString
        let routeData = self.recruit.route.map { coordinate in
            ["lat": coordinate.latitude,
             "lon": coordinate.longitude]
        }
        
        self.ref.child("recruits").child(postId).setValue(
            ["authorId": authorId,
             "title": title,
             "content": content,
             "time": time.timeIntervalSince1970,
             "meetingLocation": [
                "lat": self.recruit.meetingLocation.latitude,
                "lon": self.recruit.meetingLocation.longitude
            ],
             "route": routeData,
             "participants": []
            ])
        
        print("add recruit success")
    }
    
    func deleteRecruit(postId: String) {
        
        // Firebase 삭제
        ref.child("recruits").child(postId).removeValue { error, _ in
            
            if let error = error {
                print("삭제 실패:", error)
                return
            }
            
            print("모집 삭제 성공")
            
            // 로컬 recruits 배열에서도 제거
            self.recruits.removeAll { $0.postId == postId }
            
            // 현재 선택된 recruit 초기화 (필요하면)
            if self.recruit.postId == postId {
                self.recruit = Recruit(postId: "", authorId: "", title: "", contents: "", time: 0, meetingLocation: CLLocationCoordinate2D(), route: [], participants: [])
            }
        }
    }
    
    func fetchRecruitsList() {
        print("fetch start")
        
        ref.child("recruits").observeSingleEvent(of: .value) { snapshot in
            
            var temp: [Recruit] = []
            
            for child in snapshot.children {
                
                guard let snap = child as? DataSnapshot,
                      let value = snap.value as? [String: Any] else { continue }
                
                let postId = snap.key
                let authorId = value["authorId"] as? String ?? ""
                let title = value["title"] as? String ?? ""
                let content = value["content"] as? String ?? ""
                let time = value["time"] as? Double ?? 0
                let meetingLocation = value["meetingLocation"] as? CLLocationCoordinate2D ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
                let participants = value["participants"] as? [String] ?? []
                
                // route 파싱
                var route: [CLLocationCoordinate2D] = []
                
                if let routeArray = value["route"] as? [[String: Any]] {
                    route = routeArray.compactMap { dict in
                        
                        guard let lat = dict["lat"] as? Double,
                              let lon = dict["lon"] as? Double else { return nil }
                        
                        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    }
                }
                
                // 🔹 Recruit 생성
                let recruit = Recruit(
                    postId: postId,
                    authorId: authorId,
                    title: title,
                    contents: content,
                    time: time,
                    meetingLocation: meetingLocation,
                    route: route,
                    participants: participants
                )
                
                temp.append(recruit)
            }
            
            DispatchQueue.main.async {
                self.recruits = temp
                print("recruits updated:", temp.count)
            }
        }
    }
}

// MARK: - Participate
extension RecruitManager {
    
    func toggleParticipation(recruit: Recruit, userId: String) {
        print("userId: \(userId)")
        var updatedParticipants = recruit.participants
        
        if let index = updatedParticipants.firstIndex(of: userId) {
            // 참여 취소
            updatedParticipants.remove(at: index)
            self.ref.child("recruits").child(recruit.postId).child("participants").child(userId).removeValue()
        } else {
            // 참여
            updatedParticipants.append(userId)
            self.ref.child("recruits").child(recruit.postId).child("participants").child(userId).setValue(true)
        }
        
        // 로컬 배열 업데이트
        if let index = self.recruits.firstIndex(where: { $0.postId == recruit.postId }) {
            self.recruits[index].participants = updatedParticipants
        }
        
        // 선택된 recruit가 현재 view에 바인딩되어 있다면 업데이트
        if self.recruit.postId == recruit.postId {
            self.recruit.participants = updatedParticipants
        }
    }
    
}

