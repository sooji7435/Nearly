//
//  EditProfileView.swift
//  Nearly
//
//  Created by 박윤수 on 6/16/26.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var locationManager: LocationManager

    @Environment(\.dismiss) var dismiss

    @State private var userName: String = ""
    @State private var locationNotConfirmed: Bool = true

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 20) {

                    // 닉네임
                    VStack(alignment: .leading, spacing: 8) {
                        Text("닉네임")
                            .font(.headline)
                        TextField("닉네임을 입력해주세요.", text: $userName)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                    }

                    // 현재 위치 정보
                    if let location = userManager.user.userLocation {
                        HStack(spacing: 8) {
                            Image(systemName: "location.fill")
                                .foregroundStyle(Color.CardColor)
                                .font(.subheadline)
                            Text(location.address)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // 위치 변경 버튼
                    NavigationLink(destination: MapView(isPresented: $locationNotConfirmed)) {
                        HStack {
                            Image(systemName: locationNotConfirmed ? "location" : "location.fill")
                            Text(locationNotConfirmed ? "위치 변경하기" : "위치 변경 완료")
                        }
                        .font(.headline)
                        .foregroundStyle(locationNotConfirmed ? Color.CardColor : .green)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(locationNotConfirmed
                                      ? Color.CardColor.opacity(0.1)
                                      : Color.green.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(locationNotConfirmed
                                        ? Color.CardColor.opacity(0.3)
                                        : Color.green.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding()

                Spacer()
            }
            .navigationTitle("프로필 수정")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("저장") {
                        let location = userManager.user.userLocation
                            ?? UserLocation(lat: 0, lng: 0, address: "")
                        userManager.updateUser(userName: userName, location: location)
                        dismiss()
                    }
                    .disabled(userName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                userName = userManager.user.userName ?? ""
            }
        }
    }
}

#Preview {
    EditProfileView()
        .environmentObject(UserManager())
        .environmentObject(LocationManager())
}
