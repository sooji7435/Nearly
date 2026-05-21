//
//  RunningView.swift
//  Nearly
//
//  Created by 박윤수 on 3/13/26.
//

import SwiftUI
import Combine
import MapKit

struct RunningView: View {
    @EnvironmentObject var runningViewModel: RunningViewModel
    @EnvironmentObject var locationManager: LocationManager
    
    @State private var position: MapCameraPosition = .userLocation(
        followsHeading: true, fallback: .automatic)
    
    var body: some View {
        VStack {
            // 지도
            Map(position: $position, interactionModes: [.zoom]) {
                MapPolyline(coordinates: runningViewModel.pathCoordinates)
                    .stroke(Color.CardColor, lineWidth: 10)
            }
            .frame(height: 500)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()
            
            // 러닝 정보
            HStack(spacing: 30) {
                VStack {
                    Text("거리")
                    Text(String(format: "%.2f km", runningViewModel.distance))
                }
                VStack {
                    Text("속도")
                    Text(String(format: "%.2f km/h", runningViewModel.distance / max(runningViewModel.timeElapsed / 3600, 0.001)))
                }
                VStack {
                    Text("시간")
                    Text(runningViewModel.timeElapsed.timeString)
                }
            }
            .font(.headline)
            .padding()
            
            // 버튼
            HStack(spacing: 20) {
                Button(runningViewModel.isRunning ? "일시정지" : "시작") {
                    if !runningViewModel.isRunning {
                        locationManager.requestLocationPermission()
                        locationManager.startUpdatingLocation()
                        runningViewModel.startRunning()
                    } else {
                        runningViewModel.pauseRunning()
                        locationManager.stopUpdatingLocation()
                    }
                }
                .padding()
                .background(runningViewModel.isRunning ? Color.orange : Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("종료") {
                    runningViewModel.stopRunning()
                    locationManager.stopUpdatingLocation()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.bottom)
            
            // 기록 리스트
            List(runningViewModel.runningHistory) { run in
                HStack {
                    VStack(alignment: .leading) {
                        Text(run.date, style: .date)
                        // [FIX] 전역 distance/timeElapsed 대신 각 run의 distance 사용
                        Text(String(format: "%.2f km", run.distance))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    // run.pace는 Run 구조체의 연산 프로퍼티 (distance / time(h))
                    Text(String(format: "%.2f km/h", run.pace))
                }
            }
        }
        .navigationTitle("Running")
        .onChange(of: locationManager.userCoordinate) { _, newLocation in
            guard let location = newLocation else { return }
            runningViewModel.updateLocation(location.coordinate)
        }
    }
}

#Preview {
    RunningView()
        .environmentObject(RunningViewModel())
        .environmentObject(LocationManager())
}
