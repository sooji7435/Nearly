//
//  RecruitView.swift
//  Nearly
//
//  Created by 박윤수 on 12/18/25.
//
import SwiftUI
import CoreLocation

// MARK: - 필터 타입

enum ActivityFilter: String, CaseIterable {
    case all   = "전체"
    case mine  = "내 모집"
    case joined = "참여 중"
}

enum DistanceFilter: String, CaseIterable {
    case all     = "전체"
    case three   = "3 km"
    case five    = "5 km"
    case ten     = "10 km"

    var meters: Double? {
        switch self {
        case .all:   return nil
        case .three: return 3_000
        case .five:  return 5_000
        case .ten:   return 10_000
        }
    }
}

// MARK: - View

struct RecruitView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var recruitManager: RecruitManager
    @EnvironmentObject var appStateViewModel: AppStateViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    @State private var isLoading = false
    @State private var showAccountMenu = false
    @State private var showLogoutAlert = false
    @State private var showEditProfile = false
    @State private var activityFilter: ActivityFilter = .all
    @State private var distanceFilter: DistanceFilter = .all

    private var filteredRecruits: [Recruit] {
        recruitManager.recruits.filter { recruit in
            let passesActivity: Bool = {
                switch activityFilter {
                case .all:    return true
                case .mine:   return recruit.authorId == userManager.user.id
                case .joined: return recruit.participants.contains(userManager.user.id)
                }
            }()

            let passesDistance: Bool = {
                guard let maxMeters = distanceFilter.meters,
                      let ul = userManager.user.userLocation else { return true }
                let userCL    = CLLocation(latitude: ul.lat, longitude: ul.lng)
                let recruitCL = CLLocation(latitude: recruit.meetingLocation.latitude,
                                           longitude: recruit.meetingLocation.longitude)
                return userCL.distance(from: recruitCL) <= maxMeters
            }()

            return passesActivity && passesDistance
        }
    }

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
                    showAccountMenu = true
                } label: {
                    Image(systemName: "person.circle")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .confirmationDialog("계정", isPresented: $showAccountMenu) {
                    Button("프로필 수정") { showEditProfile = true }
                    Button("로그아웃", role: .destructive) { showLogoutAlert = true }
                    Button("취소", role: .cancel) {}
                }
                .sheet(isPresented: $showEditProfile) {
                    EditProfileView()
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
            .padding(.bottom, 4)

            // MARK: - 필터 영역
            VStack(spacing: 8) {
                // 활동 필터 (세그먼트)
                Picker("활동", selection: $activityFilter) {
                    ForEach(ActivityFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // 거리 필터 (가로 스크롤 칩)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(DistanceFilter.allCases, id: \.self) { filter in
                            Button {
                                distanceFilter = filter
                            } label: {
                                Text(filter.rawValue)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(distanceFilter == filter ? .white : Color.CardColor)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(
                                        distanceFilter == filter
                                        ? Color.CardColor
                                        : Color.CardColor.opacity(0.1)
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 4)

            Divider()

            // MARK: - List
            if isLoading {
                Spacer()
                ProgressView()
                    .scaleEffect(1.2)
                Spacer()
            } else if filteredRecruits.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "figure.run.circle")
                        .font(.system(size: 52))
                        .foregroundStyle(Color.CardColor.opacity(0.5))
                    Text(recruitManager.recruits.isEmpty ? "아직 모집이 없어요" : "조건에 맞는 모집이 없어요")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(recruitManager.recruits.isEmpty
                         ? "첫 번째 러닝 모집을 만들어보세요"
                         : "필터를 변경해보세요")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // filteredRecruits는 계산 프로퍼티라 binding이 필요한 ForEach 대신
                        // index 기반으로 원본 binding을 전달
                        ForEach(filteredRecruits) { recruit in
                            if let index = recruitManager.recruits.firstIndex(where: { $0.id == recruit.id }) {
                                RecruitListView(recruit: $recruitManager.recruits[index])
                            }
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
        .environmentObject(AppStateViewModel())
        .environmentObject(AuthenticationViewModel())
}
