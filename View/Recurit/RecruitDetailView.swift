//
//  RecruitDetailView.swift
//  Nearly
//
//  Created by 박윤수 on 1/24/26.
//

import SwiftUI
import MapKit

struct RecruitDetailView: View {
    @EnvironmentObject var recruitManager: RecruitManager
    @EnvironmentObject var userManager: UserManager
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var userId: String = ""
    
    let recruit: Recruit
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // 제목
                VStack(alignment: .leading, spacing: 8) {
                    Text(recruit.title)
                        .font(.title.bold())
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(.secondary)
                        
                        Text(recruit.timeString)
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
                
                // 설명 카드
                VStack(alignment: .leading, spacing: 12) {
                    Text("모집 설명")
                        .font(.headline)
                    
                    Text(recruit.contents)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                
                // 지도 카드
                VStack(alignment: .leading, spacing: 12) {
                    
                    Text("러닝 코스")
                        .font(.headline)
                    
                    Map(position: $cameraPosition) {
                        
                        MapPolyline(
                            coordinates: recruit.route
                        )
                        .stroke(Color.CardColor, lineWidth: 5)
                        
                        if let start = recruit.route.first {
                            Marker("Start", coordinate: start)
                                .tint(.green)
                        }
                        
                        if let end = recruit.route.last {
                            Marker("End", coordinate: end)
                                .tint(.red)
                        }
                    }
                    .frame(height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                
                // 참여 버튼
                Button {
                        recruitManager.toggleParticipation(recruit: recruit, userId: userId)
                    
                    
                } label: {
                    Text("참여하기")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(recruit.participants.contains(userId) ? Color.red : Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            userId = userManager.user.id
        }
    }
}


#Preview {
    RecruitDetailView(recruit: Recruit(postId: "123", authorId: "123", title: "한강에서 런닝하실 분~", contents: "안녕하세요 한강에서 런닝하실 분 구합니다.", time: 1710154582, route: [
        CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
        CLLocationCoordinate2D(latitude: 37.5672, longitude: 126.9795),
        CLLocationCoordinate2D(latitude: 37.5680, longitude: 126.9810),
        CLLocationCoordinate2D(latitude: 37.5690, longitude: 126.9825),
        CLLocationCoordinate2D(latitude: 37.5702, longitude: 126.9840)
    ], participants: [""]
    ))
    
    .environmentObject(RecruitManager())
    .environmentObject(UserManager())
}
 
 
