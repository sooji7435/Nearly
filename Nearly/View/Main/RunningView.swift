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

    private var currentSpeed: Double {
        runningViewModel.distance / max(runningViewModel.timeElapsed / 3600, 0.001)
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - 지도
            Map(position: $position, interactionModes: [.zoom]) {
                MapPolyline(coordinates: runningViewModel.pathCoordinates)
                    .stroke(Color.CardColor, lineWidth: 5)
            }
            .frame(height: 280)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
            .padding(.top)

            // MARK: - 통계 카드
            HStack(spacing: 12) {
                StatCard(label: "거리", value: String(format: "%.2f km", runningViewModel.distance))
                StatCard(label: "속도", value: String(format: "%.1f km/h", currentSpeed))
                StatCard(label: "시간", value: runningViewModel.timeElapsed.timeString)
            }
            .padding(.horizontal)
            .padding(.top, 16)

            // MARK: - 버튼
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
                List {
                    ForEach(runningViewModel.runningHistory.reversed()) { run in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(run.date, style: .date)
                                    .font(.subheadline)
                                Text(String(format: "%.2f km", run.distance))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(String(format: "%.1f km/h", run.pace))
                                    .font(.subheadline.weight(.medium))
                                Text(run.time.timeString)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        // reversed()이므로 실제 인덱스를 역으로 변환
                        let count = runningViewModel.runningHistory.count
                        let realOffsets = IndexSet(indexSet.map { count - 1 - $0 })
                        runningViewModel.deleteRun(at: realOffsets)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Running")
        // 러닝 중 화면 꺼짐 방지
        .onChange(of: runningViewModel.isRunning) { _, isRunning in
            UIApplication.shared.isIdleTimerDisabled = isRunning
        }
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
