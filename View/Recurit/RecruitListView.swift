//
//  RecruitListView.swift
//  Nearly
//
//  Created by 박윤수 on 1/22/26.
//

import SwiftUI
import CoreLocation

struct RecruitListView: View {
    let recruit: Recruit
    
    var body: some View {
        NavigationLink {
            RecruitDetailView(recruit: recruit)
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(recruit.title)
                        .font(.title2.bold())
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    Text(recruit.timeString)
                        .foregroundColor(.gray)
                        .font(.footnote)
                }
                    
                    Spacer()
                    
                    //MARK: - 참여자 수 표시                        
                        HStack(spacing: 4) {
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                            Text("\(recruit.participants.count)")
                        }
                        .foregroundColor(.gray)
                        .font(Font.system(size: 32))
                }
            .padding()
        }
        Divider()
    }
}



#Preview {
    RecruitListView(recruit: Recruit(postId: "123", authorId: "123", title: "Test", contents: "This is test content", time: 0, meetingLocation: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780), route: [], participants: [""]))
}

