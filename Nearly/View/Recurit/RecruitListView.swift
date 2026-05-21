//
//  RecruitListView.swift
//  Nearly
//
//  Created by 박윤수 on 1/22/26.
//

import SwiftUI
import CoreLocation

struct RecruitListView: View {
    @Binding var recruit: Recruit
    
    var body: some View {
        NavigationLink {
            RecruitDetailView(recruit: $recruit)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recruit.title)
                        .font(.headline)
                        // [FIX] .black 하드코딩 제거 → 다크모드 대응
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    Text(recruit.timeString)
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                }
                
                Spacer()
                
                // [FIX] font size 32 → 캡슐 뱃지로 교체
                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.caption)
                    Text("\(recruit.participants.count)")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(.systemGray6))
                .clipShape(Capsule())
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        Divider()
            .padding(.leading)
    }
}
