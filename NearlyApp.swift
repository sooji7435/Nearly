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
    
    //Service
    @StateObject var geo: GeocodingService = GeocodingService()
    
    //ViewModel
    @StateObject var authViewModel: AuthenticationViewModel = AuthenticationViewModel()
    @StateObject var dbViewModel: RealtimeDBViewModel = RealtimeDBViewModel()
    @StateObject var appStateViewModel: AppStateViewModel = AppStateViewModel()
    
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
            
            //Service
                .environmentObject(geo)
            
            //ViewModel
                .environmentObject(authViewModel)
                .environmentObject(dbViewModel)
                .environmentObject(appStateViewModel)
                .onAppear {
                    appStateViewModel.checkLogin()
                }
        }
        
    }
    
}
