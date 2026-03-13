//
//  RouteMapView.swift
//  Nearly
//
//  Created by 박윤수 on 3/10/26.
//

import SwiftUI
import MapKit

struct MeetMapView: View {
    @EnvironmentObject var recuitManager: RecruitManager
    
    @Environment(\.dismiss) var dismiss
    
    @State var cameraPosition: MapCameraPosition = .userLocation(
        followsHeading: false, fallback: .automatic)
    
    @Binding var meetingPoint: CLLocationCoordinate2D?

    var body: some View {
        MapReader { reader in
            Map(position: $cameraPosition) {
                if let point = meetingPoint {
                    Annotation("meeting point", coordinate: point) {
                        Text("📍")
                    }
                }
            }
            .mapControls {
                        MapUserLocationButton()
                    }
            .onTapGesture(perform: { screenCoord in
                       if let pinLocation = reader.convert(screenCoord, from: .local) {
                           meetingPoint = pinLocation
                           recuitManager.recruit.meetingLocation = pinLocation
                           print(pinLocation)
                       }
                   })
        }
        .toolbar {
            NavigationLink(destination: RouteMapView(meetingPoint: $meetingPoint)) {
                Text("다음")
            }
        }
    }
}

#Preview {
    MeetMapView(meetingPoint: .constant(CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)))
}
