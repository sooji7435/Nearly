//
//  ContentView.swift
//  Nearly
//
//  Created by 박윤수 on 12/18/25.
//
import SwiftUI

struct MainView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var recruitMananger: RecruitManager
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // MARK: -Header
                HStack {
                    Text("Nearly")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color.black)
                            .font(.title3)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                                
                // List
                ScrollView {
                    LazyVStack {
                        ForEach(recruitMananger.recruits) { recruit in
                            RecruitListView(recruit: recruit)
                        }
                    }
                }
                .onAppear {
                    recruitMananger.fetchRecruitsList()
                }
            }
            
            // MARK: - Floating Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    NavigationLink {
                        AddRecruitView()
                    } label: {
                        ZStack {
                            Capsule()
                                .frame(width: 100, height: 50)
                                .foregroundStyle(Color.card)
                            
                            Text("글쓰기")
                                .foregroundStyle(.white)
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            locationManager.requestLocation()
        }
    }
}


#Preview {
    MainView()
        .environmentObject(RecruitManager())
        .environmentObject(LocationManager())
        .environmentObject(UserManager())
}
