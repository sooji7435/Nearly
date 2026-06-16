//
//  AddRecruitView.swift
//  Nearly
//
//  Created by 박윤수 on 1/28/26.
//

import SwiftUI
import MapKit

struct AddRecruitView: View {
    @EnvironmentObject var recruitManager: RecruitManager
    @EnvironmentObject var userManager: UserManager

    @Environment(\.dismiss) var dismiss

    @State var title: String = ""
    @State var contents: String = ""
    @State var time: Date = Date().addingTimeInterval(3600)
    @State var meetingPoint: CLLocationCoordinate2D?
    @State var maxParticipants: Int = 0
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)

    private var isRouteSet: Bool { !recruitManager.recruit.route.isEmpty }
    private var canSubmit: Bool {
        !title.isEmpty && !contents.isEmpty && meetingPoint != nil && isRouteSet
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // 제목
                    VStack(alignment: .leading, spacing: 8) {
                        Text("제목")
                            .font(.headline)
                        TextField("제목을 입력해주세요", text: $title)
                            .padding(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                    }

                    // 설명
                    VStack(alignment: .leading) {
                        Text("설명")
                            .font(.headline)
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $contents)
                                .padding(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                )
                                .frame(minHeight: 150)
                            if contents.isEmpty {
                                Text("내용을 입력해주세요.")
                                    .foregroundColor(.gray.opacity(0.5))
                                    .padding(16)
                            }
                        }
                    }

                    // 시간
                    VStack(alignment: .leading, spacing: 8) {
                        Text("시간")
                            .font(.headline)
                        DatePicker(
                            "",
                            selection: $time,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .labelsHidden()
                        .tint(Color.CardColor)
                    }

                    // 최대 참여 인원
                    VStack(alignment: .leading, spacing: 8) {
                        Text("최대 참여 인원")
                            .font(.headline)
                        HStack {
                            Text(maxParticipants == 0 ? "제한 없음" : "\(maxParticipants)명")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Stepper("", value: $maxParticipants, in: 0...50)
                                .labelsHidden()
                        }
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // MARK: - Map
                    VStack(alignment: .leading, spacing: 12) {
                        Text("러닝 코스")
                            .font(.headline)

                        NavigationLink {
                            MeetMapView(meetingPoint: $meetingPoint)
                        } label: {
                            Map(position: $position, interactionModes: []) {
                                if let point = meetingPoint {
                                    Annotation("", coordinate: point) { Text("📍") }
                                }
                                if isRouteSet {
                                    MapPolyline(coordinates: recruitManager.recruit.route)
                                        .stroke(Color.CardColor, lineWidth: 4)
                                }
                            }
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .onChange(of: meetingPoint?.latitude) { _, _ in
                            guard let point = meetingPoint else { return }
                            position = .region(MKCoordinateRegion(
                                center: point,
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            ))
                        }
                    }

                    // MARK: - 작성 진행 체크리스트
                    if !canSubmit {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("작성 현황")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)

                            VStack(alignment: .leading, spacing: 6) {
                                ProgressStep(label: "제목",   done: !title.isEmpty)
                                ProgressStep(label: "설명",   done: !contents.isEmpty)
                                ProgressStep(label: "집결지 설정", done: meetingPoint != nil)
                                ProgressStep(label: "코스 그리기", done: isRouteSet)
                            }
                        }
                        .padding(14)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
            .navigationTitle("모집 만들기")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        recruitManager.addRecruit(
                            authorId: userManager.user.id,
                            title: title,
                            content: contents,
                            time: time,
                            maxParticipants: maxParticipants
                        )
                        dismiss()
                    } label: {
                        Text("확인")
                    }
                    .disabled(!canSubmit)
                }
            }
            .onDisappear {
                recruitManager.recruit = Recruit(
                    postId: "", authorId: "", title: "", contents: "",
                    time: 0, meetingLocation: CLLocationCoordinate2D(),
                    route: [], participants: []
                )
            }
        }
    }
}

// MARK: - 체크리스트 행
private struct ProgressStep: View {
    let label: String
    let done: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(done ? .green : Color(.systemGray3))
                .font(.subheadline)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(done ? .primary : .secondary)
        }
    }
}

#Preview {
    AddRecruitView()
}
