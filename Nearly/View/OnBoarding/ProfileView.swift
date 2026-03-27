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
        VStack(spacing: 20) {
            
            // MARK: - Nickname
            VStack(alignment: .leading, spacing: 10) {
                Text("닉네임")
                    .font(.headline)
                
                TextField("닉네임을 입력해주세요.", text: $userName)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
            }
            .padding()
                
                // MARK: - Request Location Button
            NavigationLink(destination: MapView(isPresented: $isPresented)) {
                    Text("위치 확인하기")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 180, height: 55)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.CardColor)
                        )
                }
            .padding()
        }
        Spacer()
        // MARK: - 완료 버튼
        .navigationTitle("프로필 설정")
        .toolbar {
            Button(action: {
                userManager.addUser(userName: userName)
                appStateViewModel.state = .main
            }) {
                Text("완료")
            }
            .disabled(isPresented || userName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserManager())
        .environmentObject(AppStateViewModel())
        .environmentObject(LocationManager())
}
