//
//  RunningViewModel.swift
//  Nearly
//
//  Created by 박윤수 on 3/13/26.
//

import SwiftUI
import CoreLocation
import Combine

class RunningViewModel: ObservableObject {
    
    @Published var distance: Double = 0
    @Published var timeElapsed: TimeInterval = 0
    @Published var isRunning = false
    @Published var runningHistory: [Run] = []
    @Published var pathCoordinates: [CLLocationCoordinate2D] = []
    
    private var previousLocation: CLLocationCoordinate2D?
    private var timer: Timer?
    
    func startRunning() {
        guard !isRunning else { return }
        isRunning = true
        distance = 0
        timeElapsed = 0
        previousLocation = nil
        pathCoordinates.removeAll()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.timeElapsed += 1
        }
    }
    
    func pauseRunning() {
        isRunning = false
        timer?.invalidate()
    }
    
    func stopRunning() {
        isRunning = false
        timer?.invalidate()
        
        // [FIX] 초기화 전에 현재 기록을 runningHistory에 저장
        // 거리가 0보다 클 때만 저장 (실수 종료 방지)
        if distance > 0 {
            let run = Run(date: Date(), distance: distance, time: timeElapsed)
            runningHistory.append(run)
        }
        
        previousLocation = nil
        distance = 0
        timeElapsed = 0
        pathCoordinates.removeAll()
    }
    
    func updateLocation(_ newCoordinate: CLLocationCoordinate2D) {
        guard isRunning else { return }
        
        if let previous = previousLocation {
            let previousCL = CLLocation(latitude: previous.latitude, longitude: previous.longitude)
            let newCL = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            let delta = newCL.distance(from: previousCL) / 1000  // km 변환
            distance += delta
        }
        
        previousLocation = newCoordinate
        pathCoordinates.append(newCoordinate)
    }
}
