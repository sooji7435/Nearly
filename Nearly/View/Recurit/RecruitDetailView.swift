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
    @State private var showEditSheet = false

    @Binding var recruit: Recruit

    private var isParticipating: Bool {
        recruit.participants.contains(userManager.user.id)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // 제목 + 메타 정보
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

                    HStack(spacing: 16) {
                        // 참여자 수
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .foregroundStyle(.secondary)
                            Text(recruit.maxParticipants > 0
                                 ? "참여자 \(recruit.participants.count)/\(recruit.maxParticipants)명"
                                 : "참여자 \(recruit.participants.count)명")
                                .foregroundStyle(recruit.isFull ? Color.orange : .secondary)
                        }
                        .font(.subheadline)

                        // 코스 거리
                        if recruit.routeDistance > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "figure.run")
                                    .foregroundStyle(.secondary)
                                Text(String(format: "%.1f km", recruit.routeDistance))
                                    .foregroundStyle(.secondary)
                            }
                            .font(.subheadline)
                        }
                    }

                    if recruit.isFull {
                        Text("모집 인원이 가득 찼습니다")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.orange)
                            .clipShape(Capsule())
                    }
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
                        Annotation("집결지", coordinate: recruit.meetingLocation) {
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

                // 버튼
                if recruit.authorId == userManager.user.id {
                    HStack(spacing: 12) {
                        Button {
                            showEditSheet = true
                        } label: {
                            Text("모집 수정")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.CardColor)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
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
                    }
                } else {
                    Button {
                        recruitManager.toggleParticipation(
                            recruit: recruit,
                            userId: userManager.user.id
                        )
                    } label: {
                        Text(recruit.isFull && !isParticipating ? "마감됨"
                             : isParticipating ? "참여 취소"
                             : "참여하기")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                recruit.isFull && !isParticipating ? Color(.systemGray4)
                                : isParticipating ? Color.red
                                : Color.blue
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(recruit.isFull && !isParticipating)
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
            .sheet(isPresented: $showEditSheet) {
                EditRecruitView(recruit: $recruit)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            let center = recruit.route.first ?? recruit.meetingLocation
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: center,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            )
        }
    }
}
