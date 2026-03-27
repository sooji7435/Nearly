//
//  APIService.swift
//  Nearly
//
//  Created by 박윤수 on 3/5/26.
//

import MapKit
import Combine
import CoreLocation

class GeocodingService {
    
    func reverseGeocode(location: CLLocation) async -> String {
            guard let request = MKReverseGeocodingRequest(location: location),
                  let response = try? await request.mapItems,
                  let address = response.first?.address?.shortAddress
            else { return "error" }
        
            return address
        }
}

