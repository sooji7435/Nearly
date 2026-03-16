//
//  LocationManager.swift
//  Nearly
//
//  Created by 박윤수 on 1/30/26.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
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
        
        // ✅ 좌표는 즉시 업데이트 (러닝 경로 추적용)
        DispatchQueue.main.async {
            self.userCoordinate = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 오류:", error)
    }
    
    // 주소 변환이 필요할 때만 호출 (프로필 설정 등)
    func updateLocation(_ location: CLLocation) async {
        let address = await geo.reverseGeocode(location: location)
        
        DispatchQueue.main.async {
            self.userCoordinate = location
            self.userLocation = UserLocation(
                lat: location.coordinate.latitude,
                lng: location.coordinate.longitude,
                address: address
            )
        }
    }
    
    // MapView에서 위치 확인 시 호출
    func fetchCurrentLocation() {
        Task {
            guard let location = userCoordinate else { return }
            await updateLocation(location)
        }
    }
    
    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
}
