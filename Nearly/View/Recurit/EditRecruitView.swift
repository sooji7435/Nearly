//
//  EditRecruitView.swift
//  Nearly
//
//  Created by 박윤수 on 6/16/26.
//

import SwiftUI

struct EditRecruitView: View {
    @EnvironmentObject var recruitManager: RecruitManager

    @Environment(\.dismiss) var dismiss

    @Binding var recruit: Recruit

    @State private var title: String
    @State private var contents: String
    @State private var time: Date
    @State private var maxParticipants: Int

    init(recruit: Binding<Recruit>) {
        self._recruit = recruit
        let r = recruit.wrappedValue
        self._title = State(initialValue: r.title)
        self._contents = State(initialValue: r.contents)
        self._time = State(initialValue: Date(timeIntervalSince1970: r.time))
        self._maxParticipants = State(initialValue: r.maxParticipants)
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

                        if maxParticipants > 0 && maxParticipants < recruit.participants.count {
                            Text("현재 참여자(\(recruit.participants.count)명)보다 작게 설정할 수 없습니다")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("모집 수정")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("저장") {
                        recruitManager.updateRecruit(
                            postId: recruit.postId,
                            title: title,
                            content: contents,
                            time: time,
                            maxParticipants: maxParticipants
                        )
                        dismiss()
                    }
                    .disabled(title.isEmpty || contents.isEmpty
                              || (maxParticipants > 0 && maxParticipants < recruit.participants.count))
                }
            }
        }
    }
}
