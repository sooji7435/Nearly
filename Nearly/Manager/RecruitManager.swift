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
    @Published var recruit: Recruit = Recruit(postId: "", authorId: "", title: "", contents: "", time: 0, meetingLocation: CLLocationCoordinate2D(latitude: 0, longitude: 0), route: [])
    @Published var recruits: [Recruit] = []
    let ref: DatabaseReference! = Database.database().reference()
    
    func addRecruit(authorId: String, title: String, content: String, time: Date) {
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
             "participants": [:]
            ])

        // Firebase 재패치 없이 로컬 배열에 즉시 반영
        let newRecruit = Recruit(
            postId: postId,
            authorId: authorId,
            title: title,
            contents: content,
            time: time.timeIntervalSince1970,
            meetingLocation: self.recruit.meetingLocation,
            route: self.recruit.route,
            participants: []
        )
        DispatchQueue.main.async {
            self.recruits.append(newRecruit)
            self.recruits.sort(by: { $0.time < $1.time })
        }
    }
    
    func deleteRecruit(postId: String) {
        ref.child("recruits").child(postId).removeValue { error, _ in
            if let error = error {
                print(error)
                return
            }
            self.recruits.removeAll { $0.postId == postId }
            if self.recruit.postId == postId {
                self.recruit = Recruit(postId: "", authorId: "", title: "", contents: "", time: 0, meetingLocation: CLLocationCoordinate2D(), route: [], participants: [])
            }
        }
    }
    
    // [FIX] completion 콜백 추가 → RecruitView 로딩 상태 연동
    func fetchRecruitsList(completion: (() -> Void)? = nil) {
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
                
                // [FIX] CLLocationCoordinate2D 직접 캐스팅 → 딕셔너리 파싱으로 수정
                var meetingLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
                if let locationDict = value["meetingLocation"] as? [String: Any],
                   let lat = locationDict["lat"] as? Double,
                   let lon = locationDict["lon"] as? Double {
                    meetingLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                }
                
                let participantsDict = value["participants"] as? [String: Any] ?? [:]
                let participants = Array(participantsDict.keys)
                
                var route: [CLLocationCoordinate2D] = []
                if let routeArray = value["route"] as? [[String: Any]] {
                    route = routeArray.compactMap { dict in
                        guard let lat = dict["lat"] as? Double,
                              let lon = dict["lon"] as? Double else { return nil }
                        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    }
                }
                
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
                self.recruits = temp.sorted(by: { $0.time < $1.time })
                completion?()
            }
        }
    }
}

// MARK: - Participate
extension RecruitManager {
    
    func toggleParticipation(recruit: Recruit, userId: String) {
        var updatedParticipants = recruit.participants
        
        if let index = updatedParticipants.firstIndex(of: userId) {
            updatedParticipants.remove(at: index)
            self.ref.child("recruits").child(recruit.postId).child("participants").child(userId).removeValue()
        } else {
            updatedParticipants.append(userId)
            self.ref.child("recruits").child(recruit.postId).child("participants").child(userId).setValue(true)
        }
        
        if let index = self.recruits.firstIndex(where: { $0.postId == recruit.postId }) {
            self.recruits[index].participants = updatedParticipants
        }
        
        if self.recruit.postId == recruit.postId {
            self.recruit.participants = updatedParticipants
        }
    }
}
