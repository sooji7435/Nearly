//
//  AppStateViewModel.swift
//  Nearly
//
//  Created by 박윤수 on 3/6/26.
//

import Foundation
import Combine

enum AppState {
    case createProfile
    case main
}

class AppStateViewModel: ObservableObject {
    @Published var state: AppState = .createProfile
    @Published var isOnboardingComplete: Bool = UserDefaults.standard.bool(forKey: "onBoardingComplete") {
        didSet {
            UserDefaults.standard.set(isOnboardingComplete, forKey: "onBoardingComplete")
        }
    }
    


    
}

