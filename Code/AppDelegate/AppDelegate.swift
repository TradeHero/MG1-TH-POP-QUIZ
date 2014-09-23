//
//  AppDelegate.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?

    var bgmPlayer = AVAudioPlayer.createAudioPlayer("Electrodoodle", extensionName: "mp3")
    
    var isSoundEffectOn: Bool {
        get{
            return bgmPlayer.playing
        }
    }
    
    private var isNotificationRegistered: Bool = false
    
    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        // Override point for customization after application launch.
        FBLoginView.self
        FBProfilePictureView.self

        #if TF
            TestFlight.takeOff(TestFlightToken)
        #endif

        
        switch kTHGamesServerMode {
        case .Staging:
            println("Current build points to Staging Server.\n")
        case .Prod:
            println("Current build points to Production Server.\n")
        }
        self.bgmPlayer.numberOfLoops = -1
        self.bgmPlayer.play()
        self.bgmPlayer.volume = kTHBackgroundMusicValue
        self.registerLoginNotification()
//        self.autoLogin()
/*
        for familyName in UIFont.familyNames() {
            let f = familyName as String
            for fontName in UIFont.fontNamesForFamilyName(f){
                println("\(fontName) - \(f)")
            }
        }
*/
        return true
    }

    func applicationWillResignActive(application: UIApplication!) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
       self.bgmPlayer.pause()
    }

    func applicationDidEnterBackground(application: UIApplication!) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        self.bgmPlayer.pause()
        self.unregisterOtherNotification()
    }

    func applicationWillEnterForeground(application: UIApplication!) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        self.bgmPlayer.play()
        self.registerOtherNotification()
    }

    func applicationDidBecomeActive(application: UIApplication!) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication!) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String, annotation: AnyObject?) -> Bool {
        var wasHandled:Bool = FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
        return wasHandled
    }
    
    func autoLogin() {
//        let client = NetworkClient.sharedClient
//        if let credential = client.credentials {
//            client.loginUserWithFacebookAuth(credential, errorHandler: {error in
//                }, loginSuccessHandler: {
//                user in
//                
//            })
//        }
    }
    
    //MARK: Login/Logout
    
    var loggedIn: Bool {
        get{
            return NSUserDefaults.standardUserDefaults().boolForKey(kTHGameLoggedInKey)
        }
        
        set(value) {
            NSUserDefaults.standardUserDefaults().setBool(value, forKey: kTHGameLoggedInKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func loginSuccessful(notification:NSNotification) {
        self.becomeFirstResponder()
        let obj = notification.userInfo
        let obj2: AnyObject? = obj!["user"]
        if let user = obj2 as? THUser {
            var vc: AnyObject! = UIStoryboard.mainStoryboard().instantiateInitialViewController()
            if let v = vc as? UINavigationController {
                self.window?.rootViewController = v
            }
            if !self.loggedIn {
                self.loggedIn = true
            }
            self.unregisterLoginNotification()
            self.registerOtherNotification()
        }
    }
    
    func registerLoginNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loginSuccessful:", name: kTHGameLoginSuccessfulNotificationKey, object: nil)
    }
    
    func unregisterLoginNotification(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kTHGameLoginSuccessfulNotificationKey, object: nil)
    }
    
    func registerOtherNotification(){
        if !self.isNotificationRegistered {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDidLogout:", name: kTHGameLogoutNotificationKey, object: nil)
            self.isNotificationRegistered = true
        }
    }
    
    func unregisterOtherNotification(){
        if self.isNotificationRegistered {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: kTHGameLogoutNotificationKey, object: nil)
            self.isNotificationRegistered = false
        }
    }
    
    func userDidLogout(notification:NSNotification){
        self.window?.rootViewController = UIStoryboard.loginStoryboard().instantiateInitialViewController() as? UIViewController
        self.unregisterOtherNotification()
        self.registerLoginNotification()
        
        self.loggedIn = false
    }
}

