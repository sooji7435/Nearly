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

                    HStack(spacing: 6) {
                        Text(recruit.timeString)
                            .foregroundStyle(.secondary)
                            .font(.footnote)

                        if recruit.routeDistance > 0 {
                            Text("·")
                                .foregroundStyle(.secondary)
                                .font(.footnote)
                            Text(String(format: "%.1f km", recruit.routeDistance))
                                .foregroundStyle(.secondary)
                                .font(.footnote)
                        }
                    }
                }

                Spacer()

                // 참여자 수 (최대 인원 포함)
                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.caption)
                    Text(recruit.maxParticipants > 0
                         ? "\(recruit.participants.count)/\(recruit.maxParticipants)"
                         : "\(recruit.participants.count)")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundStyle(recruit.isFull ? Color.orange : .secondary)
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
