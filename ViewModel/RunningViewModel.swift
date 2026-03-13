
//
//  RunningView.swift
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
    
    // 외부 위치 업데이트 처리
    
    
    func startRunning() {
        guard !isRunning else { return }
        isRunning = true
        distance = 0
        timeElapsed = 0
        previousLocation = nil
        pathCoordinates.removeAll()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.timeElapsed += 1
            

        }
    }
    
    func pauseRunning() {
        isRunning = false
        timer?.invalidate()
    }
    
    func stopRunning() {
        isRunning = false
        timer?.invalidate()
        previousLocation = nil
        distance = 0
        timeElapsed = 0
        pathCoordinates.removeAll()
    }
}

