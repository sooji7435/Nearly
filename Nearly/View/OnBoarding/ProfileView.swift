//
//  ProfileView.swift
//  Nearly
//
//  Created by 박윤수 on 3/6/26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var appStateViewModel: AppStateViewModel
    @EnvironmentObject var locationManager: LocationManager
    
    @State private var userName: String = ""
    @State var isPresented: Bool = true
    
    var body: some View {
        // [FIX] Spacer()가 VStack 밖에 나와 modifier가 엉뚱한 뷰에 붙던 문제 수정
        // 전체를 하나의 VStack으로 감싸고 modifier를 VStack에 붙임
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - Nickname
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
                
                // MARK: - 위치 확인 버튼
                NavigationLink(destination: MapView(isPresented: $isPresented)) {
                    HStack {
                        Image(systemName: isPresented ? "location" : "location.fill")
                        Text(isPresented ? "위치 확인하기" : "위치 확인 완료")
                    }
                    .font(.headline)
                    .foregroundStyle(isPresented ? Color.CardColor : .green)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(isPresented ? Color.CardColor.opacity(0.1) : Color.green.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isPresented ? Color.CardColor.opacity(0.3) : Color.green.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("프로필 설정")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    userManager.addUser(userName: userName)
                    appStateViewModel.state = .main
                } label: {
                    Text("완료")
                }
                .disabled(isPresented || userName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(UserManager())
            .environmentObject(AppStateViewModel())
            .environmentObject(LocationManager())
    }
}
