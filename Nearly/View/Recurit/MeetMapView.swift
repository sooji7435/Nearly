//
//  MeetMapView.swift
//  Nearly
//
//  Created by 박윤수 on 3/10/26.
//

import SwiftUI
import MapKit
import CoreLocation

struct MeetMapView: View {
    @EnvironmentObject var recruitManager: RecruitManager

    @Environment(\.dismiss) var dismiss

    @State var cameraPosition: MapCameraPosition = .userLocation(
        followsHeading: false, fallback: .automatic)
    @State private var address: String = ""
    @State private var isGeocoding = false

    @Binding var meetingPoint: CLLocationCoordinate2D?

    private let geo = GeocodingService()

    var body: some View {
        ZStack(alignment: .bottom) {
            MapReader { reader in
                Map(position: $cameraPosition) {
                    if let point = meetingPoint {
                        Annotation("집결지", coordinate: point) {
                            Text("📍")
                        }
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                }
                .onTapGesture { screenCoord in
                    guard let pinLocation = reader.convert(screenCoord, from: .local) else { return }
                    meetingPoint = pinLocation
                    recruitManager.recruit.meetingLocation = pinLocation
                    // 탭한 위치의 주소를 역지오코딩
                    isGeocoding = true
                    Task {
                        let location = CLLocation(latitude: pinLocation.latitude,
                                                  longitude: pinLocation.longitude)
                        address = await geo.reverseGeocode(location: location)
                        isGeocoding = false
                    }
                }
            }

            // 주소 표시 오버레이
            if meetingPoint != nil {
                HStack(spacing: 6) {
                    if isGeocoding {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(Color.CardColor)
                    }
                    Text(isGeocoding ? "주소 확인 중..." : address)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 4)
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
        .toolbar {
            NavigationLink(destination: RouteMapView(meetingPoint: $meetingPoint)) {
                Text("다음")
            }
            .disabled(meetingPoint == nil)
        }
    }
}

#Preview {
    MeetMapView(meetingPoint: .constant(CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)))
}
