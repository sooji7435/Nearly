//
//  DateService.swift
//  Nearly
//
//  Created by 박윤수 on 3/12/26.
//

import SwiftUI

extension DateFormatter {
    static let recruitFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 HH:mm"
        return formatter
    }()
}

// 시간 포맷 함수
extension TimeInterval {
    var timeString: String {
        let h = Int(self) / 3600
        let m = Int(self) / 60 % 60
        let s = Int(self) % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}
