//
//  NearlyApp.swift
//  Nearly
//
//  Created by 박윤수 on 12/18/25.
//

import SwiftUI
import KakaoSDKCommon
import NidThirdPartyLogin
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        NidOAuth.shared.initialize(
            appName: "Nearly",
            clientId: "xGFaWx8kAr66c0OJjHIx",
            clientSecret: "0JzKvXGHON",
            urlScheme: "Nearly"
        )
        return true
    }
}

@main
struct Nearly: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    //Manager
    @StateObject var locationManager: LocationManager = LocationManager()
    @StateObject var userManager: UserManager = UserManager()
    @StateObject var recruitManager: RecruitManager = RecruitManager()
    
    //ViewModel
    @StateObject var authViewModel: AuthenticationViewModel = AuthenticationViewModel()
    @StateObject var appStateViewModel: AppStateViewModel = AppStateViewModel()
    @StateObject var runningViewModel: RunningViewModel = RunningViewModel()
    
    init() {
        KakaoSDK.initSDK(appKey: "8ccbb76509da0aaf5a266b99bb5a8521")
    }
    
    
    var body: some Scene {
        WindowGroup {
            RootView()
            
            //Manager
                .environmentObject(locationManager)
                .environmentObject(userManager)
                .environmentObject(recruitManager)
            
            //ViewModel
                .environmentObject(authViewModel)
                .environmentObject(appStateViewModel)
                .environmentObject(runningViewModel)
                .onAppear {
                    appStateViewModel.checkLogin()
                }
        }
        
    }
    
}
