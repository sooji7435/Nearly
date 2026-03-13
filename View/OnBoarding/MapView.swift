//
//  MapView.swift
//  Nearly
//
//  Created by 박윤수 on 1/30/26.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var app: AppStateViewModel
    @EnvironmentObject var userManager: UserManager
    
    @Environment(\.dismiss) var dismiss
    
    @State private var position: MapCameraPosition = .userLocation(
        followsHeading: false, fallback: .automatic)
    
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            // MARK: - Map
            Map(position: $position, interactionModes: [])
            
                // MARK: - Location Info
            VStack {
                VStack {
                    Spacer()
                    
                    if let location = locationManager.userLocation {
                        Text("현재 위치는 \(location.address)입니다.")
                            .font(.caption)
                            .padding(8)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 3)
                    } else {
                        Text("위치 정보를 가져오는 중입니다...")
                            .font(.caption)
                            .padding(8)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 3)
                    }
                    
                    // MARK: - Location Check button
                    Button(action: {
                        locationManager.requestLocationPermission()
                        locationManager.requestLocation()
                        userManager.user.userLocation = locationManager.userLocation
                        isPresented = false
                    }) {
                        Text("내 위치 확인")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 180, height: 55)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.CardColor)
                            )
                    }
                }
            }
        }
        // MARK: - Confirm Location Button
        .toolbar {
            Button(action: {
                
                dismiss()
            }) {
                Text("확인")
            }
            .disabled(isPresented)
        }
    }
}

#Preview {
    MapView(isPresented: .constant(true))
        .environmentObject(LocationManager())
        .environmentObject(AppStateViewModel())
    
}
