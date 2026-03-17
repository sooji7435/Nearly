//
//  ContentView.swift
//  Nearly
//
//  Created by 박윤수 on 12/18/25.
//
import SwiftUI

struct RecruitView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var recruitManager: RecruitManager
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // MARK: -Header
                HStack {
                    Text("Nearly")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // List
                ScrollView {
                    LazyVStack {
                        ForEach($recruitManager.recruits) { $recruit in
                            RecruitListView(recruit: $recruit)
                        }
                    }
                }
                .onAppear {
                    recruitManager.fetchRecruitsList()
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
    }
}


#Preview {
    RecruitView()
        .environmentObject(RecruitManager())
        .environmentObject(LocationManager())
        .environmentObject(UserManager())
}
