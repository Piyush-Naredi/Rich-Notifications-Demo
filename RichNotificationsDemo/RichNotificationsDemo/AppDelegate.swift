//
//  AppDelegate.swift
//  RichNotificationsDemo
//
//  Created by Piyush Naredi on 16/02/18.
//  Copyright © 2018 Piyush Naredi. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //request authorization for asking permission to receive notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                UNUserNotificationCenter.current().delegate = self
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                    
                    //adding actions in rich notification by using category
                    self.setNotificationCategory()
                }
                print("Success")
            } else {
                print("failure")
                
            }
        }
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format:"%02.2hhx", data)
        }
        //        let pushnoti = UNUs
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error:\(error.localizedDescription)")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        //app groups used for sharing data from extension to application or vice versa. It's optional. Not related to rich notification
        let sharedDataSession = UserDefaults(suiteName: "group.com.company.RichNotificationsDemo")!
        let decoded  = sharedDataSession.value(forKey: "notificationContent") as? Data
        let commentText = sharedDataSession.value(forKey: "commentValue") as? String
        if decoded != nil && commentText != nil {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "ShowData"), object: nil, userInfo: ["flag":"1", "decodedString": decoded!, "commentValue": commentText!])
            sharedDataSession.removeObject(forKey: "commentValue")
            sharedDataSession.removeObject(forKey: "notificationContent")
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "HideData"), object: nil, userInfo: nil)
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.badge,.sound])
    }
    
    
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        print(userInfo)
//    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let actionIdentifier = response.actionIdentifier
        if actionIdentifier == "snooze" {
            print("Hello")
            let newContent = response.notification.request.content.mutableCopy() as? UNMutableNotificationContent
            newContent?.title += " Again Reminder"
            let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
            let request = UNNotificationRequest(identifier: "Repeat", content: newContent!, trigger: notificationTrigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
        completionHandler()
    }
    
    func setNotificationCategory() {
        
        //creating actions
        let likeAction = UNNotificationAction(identifier: "like", title:"Like", options: .authenticationRequired)
        let snoozeAction = UNNotificationAction(identifier: "snooze", title: "Snooze", options: .destructive)
        let  ccommentAction = UNTextInputNotificationAction(identifier: "comment", title: "Comment", options: .foreground)
        let  cancelAction = UNNotificationAction(identifier: "cancel", title: "Cancel", options: .destructive)

        //creating actions and adding respective action of them.
        //here identifier name must match to the category name identifier sended in notification payload and content extension used otherwise actions will not be shown to you.
        let customViewCategory1 = UNNotificationCategory(identifier: "customViewCategory1", actions: [likeAction,snoozeAction, ccommentAction, cancelAction], intentIdentifiers: [], options: [])
        
        let customViewCategory2 = UNNotificationCategory(identifier: "customViewCategory2", actions: [likeAction, cancelAction], intentIdentifiers: [], options: [])
        
        let foodItemCategory = UNNotificationCategory(identifier: "foodItemCategory", actions: [snoozeAction, cancelAction], intentIdentifiers: [], options: [])

        let defaultCategory =  UNNotificationCategory(identifier: "defaultCategory", actions: [snoozeAction, cancelAction], intentIdentifiers: [], options: [])

        UNUserNotificationCenter.current().setNotificationCategories([customViewCategory1, customViewCategory2, foodItemCategory, defaultCategory])
    }
}

