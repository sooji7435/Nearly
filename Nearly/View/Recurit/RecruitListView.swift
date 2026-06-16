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

    private var isExpired: Bool {
        Date().timeIntervalSince1970 > recruit.time
    }

    var body: some View {
        NavigationLink {
            RecruitDetailView(recruit: $recruit)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(recruit.title)
                            .font(.headline)
                            .foregroundStyle(isExpired ? .secondary : .primary)
                            .lineLimit(1)

                        if isExpired {
                            Text("마감")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.secondary)
                                .clipShape(Capsule())
                        }
                    }

                    Text(recruit.timeString)
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                }

                Spacer()

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
            .opacity(isExpired ? 0.6 : 1.0)
        }
        Divider()
            .padding(.leading)
    }
}
