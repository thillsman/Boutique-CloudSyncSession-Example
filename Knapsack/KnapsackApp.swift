//
//  KnapsackApp.swift
//  Knapsack
//
//  Created by Tyler Hillsman on 4/5/23.
//

import SwiftUI
import CloudKit

@main
struct KnapsackApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        application.registerForRemoteNotifications()
        return true
    }
        
    func application(_: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let notification = CKNotification(fromRemoteNotificationDictionary: userInfo),
            notification.subscriptionID == KnapsackSession.subscriptionID {
            
            NotificationCenter.default.post(name: Notification.Name("fetchCloudKit"), object: nil)
            
            // Initiate a fetch request with the most recent change token
            // Wait some time to see if that fetch operation finishes in time
            // Call completionHandler with the appropriate value

            return
        }

        // Handle other kinds of notifications
    }
}
