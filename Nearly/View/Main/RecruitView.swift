//
//  RecruitView.swift
//  Nearly
//
//  Created by 박윤수 on 12/18/25.
//
import SwiftUI

struct RecruitView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var recruitManager: RecruitManager
    @EnvironmentObject var appStateViewModel: AppStateViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    @State private var isLoading = false
    @State private var showLogoutAlert = false

    var body: some View {
        NavigationStack {
            // MARK: - Header
            HStack {
                Text("Nearly")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Spacer()

                NavigationLink {
                    AddRecruitView()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.subheadline.weight(.semibold))
                        Text("글쓰기")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(Color.CardColor)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.CardColor.opacity(0.12))
                    .clipShape(Capsule())
                }

                Button {
                    showLogoutAlert = true
                } label: {
                    Image(systemName: "person.circle")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .alert("로그아웃", isPresented: $showLogoutAlert) {
                    Button("로그아웃", role: .destructive) {
                        if let platform = appStateViewModel.getLoginPlatform() {
                            authViewModel.signOut(platform: platform)
                        }
                        appStateViewModel.logout()
                    }
                    Button("취소", role: .cancel) {}
                } message: {
                    Text("로그아웃 하시겠습니까?")
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 8)
            
            Divider()
            
            // MARK: - List
            if isLoading {
                // [FIX] 로딩 중 스피너
                Spacer()
                ProgressView()
                    .scaleEffect(1.2)
                Spacer()
            } else if recruitManager.recruits.isEmpty {
                // [FIX] 빈 상태 화면
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "figure.run.circle")
                        .font(.system(size: 52))
                        .foregroundStyle(Color.CardColor.opacity(0.5))
                    Text("아직 모집이 없어요")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("첫 번째 러닝 모집을 만들어보세요")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach($recruitManager.recruits) { $recruit in
                            RecruitListView(recruit: $recruit)
                        }
                    }
                }
                .refreshable {
                    await withCheckedContinuation { continuation in
                        recruitManager.fetchRecruitsList {
                            continuation.resume()
                        }
                    }
                }
            }
        }
        .onAppear {
            isLoading = true
            recruitManager.fetchRecruitsList {
                isLoading = false
            }
        }
    }
}

#Preview {
    RecruitView()
        .environmentObject(RecruitManager())
        .environmentObject(LocationManager())
        .environmentObject(UserManager())
}
