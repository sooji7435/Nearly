//
//  Untitled.swift
//  Nearly
//
//  Created by 박윤수 on 1/30/26.
//

import Foundation
import CoreLocation
import Combine

class LocationManager:  NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userCoordinate: CLLocation?
    @Published var userLocation: UserLocation?
    
    private let manager = CLLocationManager()
    private let geo = GeocodingService()
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func requestLocationPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        
        Task {
            await updateLocation(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 오류:", error)
    }
    
    func updateLocation(_ location: CLLocation) async {
        let address = await geo.reverseGeocode(location: location)
        
        self.userCoordinate = location
        self.userLocation = UserLocation(
            lat: location.coordinate.latitude,
            lng: location.coordinate.longitude,
            address: address
        )
    }
    
    func startUpdatingLocation() {
            manager.startUpdatingLocation()
        }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
}
