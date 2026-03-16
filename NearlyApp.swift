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
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in
            
        }
        
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
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(String(describing: fcmToken))")

      let dataDict: [String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(
        name: Notification.Name("FCMToken"),
        object: nil,
        userInfo: dataDict
      )
      // TODO: If necessary send token to application server.
      // Note: This callback is fired at each app startup and whenever a new token is generated.
        print("토큰 저장됨")
        UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner])
    }
    
    func application(_ application: UIApplication,
                         didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            print("APNS token: \(deviceToken)")
            Messaging.messaging().apnsToken = deviceToken
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
                    
                    if let userId = UserDefaults.standard.string(forKey: "userId") {
                            userManager.user.id = userId
                            userManager.fetchUserInfo(userID: userId) { _ in }
                        }
                }
        }
        
        
    }
    
    
}
