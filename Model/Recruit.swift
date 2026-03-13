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
    
    var timeString: String {
            let date = Date(timeIntervalSince1970: time)
            return DateFormatter.recruitFormatter.string(from: date)
        }
    
    var id: String {postId}
}


