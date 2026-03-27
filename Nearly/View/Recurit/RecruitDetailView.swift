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
    
    @Environment(\.dismiss) var dismiss
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var showDeleteAlert = false
    
    @Binding var recruit: Recruit
    
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
                        Annotation("meeting point", coordinate: recruit.meetingLocation) {
                            Text("📍")
                        }
                        MapPolyline(coordinates: recruit.route)
                            .stroke(Color.CardColor, lineWidth: 5)
                        
                        if let start = recruit.route.first {
                            Marker("Start", coordinate: start).tint(.green)
                        }
                        if let end = recruit.route.last {
                            Marker("End", coordinate: end).tint(.red)
                        }
                    }
                    .frame(height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                // 참여 버튼
                if recruit.authorId == userManager.user.id {
                    // 작성자 → 삭제 버튼
                    Button {
                        showDeleteAlert = true
                    } label: {
                        Text("모집 삭제")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                } else {
                    // 일반 유저 → 참여 버튼
                    Button {
                        recruitManager.toggleParticipation(
                            recruit: recruit,
                            userId: userManager.user.id
                        )
                    } label: {
                        Text(
                            recruit.participants.contains(userManager.user.id)
                            ? "참여 취소"
                            : "참여하기"
                        )
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            recruit.participants.contains(userManager.user.id)
                            ? Color.red
                            : Color.blue
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding()
            .alert("모집 삭제", isPresented: $showDeleteAlert) {
                Button("삭제", role: .destructive) {
                    recruitManager.deleteRecruit(postId: recruit.postId)
                    dismiss()
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("이 모집글을 삭제하시겠습니까?")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let first = recruit.route.first {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: first,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                )
            }
        }
    }
}
