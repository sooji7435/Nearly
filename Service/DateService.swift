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
