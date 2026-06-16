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
    private var isPaused = false
    private let historyKey = "runningHistory"

    init() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let saved = try? JSONDecoder().decode([Run].self, from: data) {
            runningHistory = saved
        }
    }

    private func saveHistory() {
        if let data = try? JSONEncoder().encode(runningHistory) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }

    func startRunning() {
        guard !isRunning else { return }
        isRunning = true

        // 일시정지에서 재개할 때는 기록을 유지, 새 러닝 시작 시에만 초기화
        if !isPaused {
            distance = 0
            timeElapsed = 0
            previousLocation = nil
            pathCoordinates.removeAll()
        }
        isPaused = false

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.timeElapsed += 1
        }
    }

    func pauseRunning() {
        isRunning = false
        isPaused = true
        timer?.invalidate()
    }

    func stopRunning() {
        isRunning = false
        isPaused = false
        timer?.invalidate()

        if distance > 0 {
            let run = Run(date: Date(), distance: distance, time: timeElapsed)
            runningHistory.append(run)
            saveHistory()
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
