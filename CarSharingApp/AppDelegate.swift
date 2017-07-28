//
//  AppDelegate.swift
//  CarSharingApp
//
//  Created by Chavane Minto on 7/11/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import Parse
import GooglePlaces
import GoogleMaps
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Initialize Parse
        // Set applicationId and server based on the values in the Heroku settings.
        // clientKey is not used on Parse open source unless explicitly configured
        Parse.initialize(
            with: ParseClientConfiguration(block: { (configuration: ParseMutableClientConfiguration) -> Void in
                configuration.applicationId = "Merge"
                configuration.clientKey = "mergeMasterKey"  // set to nil assuming you have not set clientKey
                configuration.server = "https://merge-carsharingapp.herokuapp.com/parse"
                GMSServices.provideAPIKey("AIzaSyB3pylgXIl9EWzX1GpfXgfRtFag7VInqsU")
                GMSPlacesClient.provideAPIKey("AIzaSyB3pylgXIl9EWzX1GpfXgfRtFag7VInqsU")
            })
        )
        
        //this enables user to be persisted across app restarts

        if let currentUser = PFUser.current() {
            print("Welcome back \(currentUser.username!) 😍")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBarViewController = storyboard.instantiateViewController(withIdentifier: "tabBar")
            window?.rootViewController = tabBarViewController
        }
        
        //log user out
        NotificationCenter.default.addObserver(forName: NSNotification.Name("logoutNotification"), object: nil, queue: OperationQueue.main) { (Notification) in
            // Take user to logout screen
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            self.window?.rootViewController = loginViewController
        }
        
        //Set up push notifications
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            if granted {
                UIApplication.shared.registerForRemoteNotifications()
            }
            
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        // Print notification payload data
        print("Push notification received: \(data)")
        
        /*
         Note that this callback will only be invoked whenever the user has either clicked or swiped to interact with your push notification from the lock screen / Notification Center, or if your app was open when the push notification was received by the device.
         
         It's up to you to develop the actual logic that gets executed when a notification is interacted with. For example, if you have a messenger app, a "new message" push notification should open the relevant chat page and cause the list of messages to be updated from the server. Make use of the data object which will contain any data that you send from your application backend, such as the chat ID, in the messenger app example.
         
         It's important to note that in the event your app is open when a push notification is received, the user will not see the notification at all, and it is up to you to notify the user in some way. This StackOverflow question lists some possible workarounds, such as displaying an in-app banner similar to the stock iOS notification banner.
 
        */
    }
    
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.current()
        installation?.setDeviceTokenFrom(deviceToken as Data)
        installation?.saveInBackground()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handle(userInfo)
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
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

