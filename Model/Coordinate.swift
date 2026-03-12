//
//  Coordinate.swift
//  Nearly
//
//  Created by 박윤수 on 3/11/26.
//

import Foundation
import CoreLocation

struct Coordinate {
    var latitude: Double
    var longitude: Double
    
    var clLocation: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension Coordinate {
    var dictionary: [String: Double] {
        [
            "latitude": latitude,
            "longitude": longitude
        ]
    }
}
