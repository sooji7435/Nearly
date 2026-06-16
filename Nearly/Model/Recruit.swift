//
//  Recruit.swift
//  Nearly
//
//  Created by 박윤수 on 1/22/26.
//

import Foundation
import CoreLocation

struct Recruit: Identifiable {
    let postId: String
    let authorId: String
    var title: String
    var contents: String
    var time: Double
    var meetingLocation: CLLocationCoordinate2D
    var route: [CLLocationCoordinate2D]
    var participants: [String] = []
    var maxParticipants: Int = 0  // 0 = 제한 없음

    var timeString: String {
        let date = Date(timeIntervalSince1970: time)
        return DateFormatter.recruitFormatter.string(from: date)
    }

    var id: String { postId }

    // 경로 총 거리 (km)
    var routeDistance: Double {
        guard route.count > 1 else { return 0 }
        var total = 0.0
        for i in 1..<route.count {
            let from = CLLocation(latitude: route[i-1].latitude, longitude: route[i-1].longitude)
            let to   = CLLocation(latitude: route[i].latitude,   longitude: route[i].longitude)
            total += from.distance(from: to)
        }
        return total / 1000
    }

    // 인원 초과 여부 (maxParticipants == 0이면 항상 false)
    var isFull: Bool {
        maxParticipants > 0 && participants.count >= maxParticipants
    }
}
