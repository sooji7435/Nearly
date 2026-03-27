//
//  MainView.swift
//  Nearly
//
//  Created by 박윤수 on 3/13/26.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            Tab("Recruit", systemImage: "map.fill") {
               RecruitView()
            }
            
            Tab("Running", systemImage: "figure.run") {
                RunningView()
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(RecruitManager())
        .environmentObject(UserManager())
}
