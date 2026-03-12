//
//  RouteMapView.swift
//  Nearly
//
//  Created by 박윤수 on 3/10/26.
//

import SwiftUI
import MapKit

struct RouteMapView: View {
    @EnvironmentObject var recruitManager: RecruitManager
    
    @Environment(\.dismiss) var dismiss
    
    @State var cameraPosition: MapCameraPosition = .userLocation(
        followsHeading: false, fallback: .automatic)
    @State private var routeCoordinates: [CLLocationCoordinate2D] = []
    @State private var isDrawingMode = false
    
    @Binding var meetingPoint: CLLocationCoordinate2D?
    
    var body: some View {
        ZStack {
            MapReader { reader in
                Map(position: $cameraPosition, interactionModes: isDrawingMode ? [] : .all) {
                    if let point = meetingPoint {
                        Annotation("meeting point", coordinate: point) {
                            Text("📍")
                        }
                        
                        MapPolyline(coordinates: routeCoordinates)
                            .stroke(Color.CardColor, lineWidth: 4)
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            // DragGesture.Value → CGPoint
                            let screenPoint = value.location
                            
                            // CGPoint → 지도 좌표
                            if let newCoord = reader.convert(screenPoint, from: .local) {
                                routeCoordinates.append(newCoord)
                                print(newCoord)
                            }
                        }
                )
            }
            
            VStack {
                Spacer()
                if !isDrawingMode {
                    Button(action: {isDrawingMode = true}) {
                        Text("경로 그리기")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 180, height: 55)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.CardColor)
                            )
                    }
                }
                
                else {
                    Button(action: {isDrawingMode = false}) {
                        Text("경로 그리기 완료")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 180, height: 55)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.CardColor)
                            )
                    }
                    
                    Text("드래그하여 경로를 그리세요")
                        .font(.caption)
                        .padding(8)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 3)
                }
            }
            .toolbar {
                Button(action: {routeCoordinates = []}) {
                    Image(systemName: "eraser.fill")
                }

                Button(action: {
                        recruitManager.recruit.route = routeCoordinates
                        dismiss()
                }) {
                    Text("확인")
                }
                
            }
        }
    }
}

#Preview {
    RouteMapView(meetingPoint: .constant(CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)))
}

