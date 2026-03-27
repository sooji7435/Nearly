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
    
    @State private var coordinates: [CLLocationCoordinate2D] = []
    
    
    @State var title: String = ""
    @State var contents: String = ""
    @State var time: Date = Date().addingTimeInterval(3600)
    @State var meetingPoint: CLLocationCoordinate2D?
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
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
                        
                        Spacer()
                    }
                    
                    // MARK: - Map
                    VStack(alignment: .leading, spacing: 12) {
                        Text("러닝 코스")
                            .font(.headline)
                        
                        NavigationLink {
                            MeetMapView(meetingPoint: $meetingPoint)
                        } label: {
                            Map(position: $position, interactionModes: [])
                                .frame(height: 260)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    
                }
                .padding()
            }
            .navigationTitle("모집 만들기")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {

                            recruitManager.addRecruit(
                                authorId: userManager.user.id,
                                title: title,
                                content: contents,
                                time: time,
                            )
                        
                        dismiss()
                    }) {
                        Text("확인")
                    }
                    .disabled(title.isEmpty || contents.isEmpty || meetingPoint == nil || recruitManager.recruit.route.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddRecruitView()
}
