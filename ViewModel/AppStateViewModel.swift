//
//  AppStateViewModel.swift
//  Nearly
//
//  Created by 박윤수 on 3/6/26.
//

import Foundation
import Combine

enum AppState {
    case login
    case createProfile
    case main
}

class AppStateViewModel: ObservableObject {
    @Published var state: AppState = .login
    }
    


    


