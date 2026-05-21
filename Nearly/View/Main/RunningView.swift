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
    
    // 현재 속도 계산 (0으로 나누기 방지)
    private var currentSpeed: Double {
        runningViewModel.distance / max(runningViewModel.timeElapsed / 3600, 0.001)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - 지도
            // [FIX] 500 → 280pt로 축소 — 버튼·통계·기록 목록이 잘리지 않도록
            Map(position: $position, interactionModes: [.zoom]) {
                MapPolyline(coordinates: runningViewModel.pathCoordinates)
                    .stroke(Color.CardColor, lineWidth: 5)
            }
            .frame(height: 280)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
            .padding(.top)
            
            // MARK: - 통계 카드
            // [FIX] HStack 나열 → 카드 그리드로 시각적 구분 강화
            HStack(spacing: 12) {
                StatCard(label: "거리", value: String(format: "%.2f km", runningViewModel.distance))
                StatCard(label: "속도", value: String(format: "%.1f km/h", currentSpeed))
                StatCard(label: "시간", value: runningViewModel.timeElapsed.timeString)
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            // MARK: - 버튼
            // [FIX] 시작/일시정지 버튼을 더 크게, 종료는 서브 크기로 위계 구분
            HStack(spacing: 12) {
                Button {
                    if !runningViewModel.isRunning {
                        locationManager.requestLocationPermission()
                        locationManager.startUpdatingLocation()
                        runningViewModel.startRunning()
                    } else {
                        runningViewModel.pauseRunning()
                        locationManager.stopUpdatingLocation()
                    }
                } label: {
                    Label(
                        runningViewModel.isRunning ? "일시정지" : "시작",
                        systemImage: runningViewModel.isRunning ? "pause.fill" : "play.fill"
                    )
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(runningViewModel.isRunning ? Color.orange : Color.green)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                
                Button {
                    runningViewModel.stopRunning()
                    locationManager.stopUpdatingLocation()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.headline)
                        .frame(width: 52, height: 52)
                        .background(Color(.systemGray5))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal)
            .padding(.top, 14)
            
            // MARK: - 기록 리스트
            if runningViewModel.runningHistory.isEmpty {
                Spacer()
                Text("러닝을 완료하면 기록이 쌓여요")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                List(runningViewModel.runningHistory) { run in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(run.date, style: .date)
                                .font(.subheadline)
                            // [FIX] 전역 distance 대신 run.distance 사용
                            Text(String(format: "%.2f km", run.distance))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        // [FIX] run.pace 사용 (Run 구조체 연산 프로퍼티)
                        Text(String(format: "%.1f km/h", run.pace))
                            .font(.subheadline.weight(.medium))
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Running")
        .onChange(of: locationManager.userCoordinate) { _, newLocation in
            guard let location = newLocation else { return }
            runningViewModel.updateLocation(location.coordinate)
        }
    }
}

// MARK: - 통계 카드 컴포넌트
private struct StatCard: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(.subheadline, design: .monospaced, weight: .semibold))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    RunningView()
        .environmentObject(RunningViewModel())
        .environmentObject(LocationManager())
}
