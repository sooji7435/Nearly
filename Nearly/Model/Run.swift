//
//  Run.swift
//  Nearly
//
//  Created by 박윤수 on 3/13/26.
//
import Foundation

struct Run: Identifiable, Codable {
    let id: UUID
    let date: Date
    let distance: Double   // km
    let time: TimeInterval // seconds
    var pace: Double { distance / (time / 3600) } // km/h

    enum CodingKeys: String, CodingKey {
        case id, date, distance, time
    }

    init(date: Date, distance: Double, time: TimeInterval) {
        self.id = UUID()
        self.date = date
        self.distance = distance
        self.time = time
    }
}
