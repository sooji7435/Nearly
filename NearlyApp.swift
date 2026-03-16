//
//  NearlyApp.swift
//  Nearly
//
//  Created by 박윤수 on 12/18/25.
//

import SwiftUI
import UserNotifications
import KakaoSDKCommon
import NidThirdPartyLogin
import Firebase
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
        
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        
        NidOAuth.shared.initialize(
            appName: "Nearly",
            clientId: "xGFaWx8kAr66c0OJjHIx",
            clientSecret: "0JzKvXGHON",
            urlScheme: "Nearly"
        )
        return true
    }
    
    // FCM 토큰 발급 / 갱신 시 호출
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("FCM 토큰 저장됨: \(token)")
        UserDefaults.standard.set(token, forKey: "fcmToken")
    }
    
    // 앱 포그라운드 상태에서도 알림 표시
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner])
    }
    
    // APNs 토큰 → Firebase 전달
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNS token: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }
}

@main
struct Nearly: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Manager
    @StateObject var locationManager: LocationManager = LocationManager()
    @StateObject var userManager: UserManager = UserManager()
    @StateObject var recruitManager: RecruitManager = RecruitManager()
    
    // ViewModel
    @StateObject var authViewModel: AuthenticationViewModel = AuthenticationViewModel()
    @StateObject var appStateViewModel: AppStateViewModel = AppStateViewModel()
    @StateObject var runningViewModel: RunningViewModel = RunningViewModel()
    
    init() {
        KakaoSDK.initSDK(appKey: "8ccbb76509da0aaf5a266b99bb5a8521")
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                // Manager
                .environmentObject(locationManager)
                .environmentObject(userManager)
                .environmentObject(recruitManager)
                // ViewModel
                .environmentObject(authViewModel)
                .environmentObject(appStateViewModel)
                .environmentObject(runningViewModel)
                .onAppear {
                    appStateViewModel.checkLogin()
                    
                    // 자동 로그인 시 유저 정보 복원
                    if let userId = UserDefaults.standard.string(forKey: "userId") {
                        userManager.user.id = userId
                        userManager.fetchUserInfo(userID: userId) { _ in }
                    }
                }
        }
    }
}
