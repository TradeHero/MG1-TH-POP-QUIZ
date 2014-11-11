//
//  AppDelegate.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import AVFoundation

let kTHGamesServerMode = Mode.Prod

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CHDraggingCoordinatorDelegate {
    
    var window: UIWindow?
    var loginOnce = false
    var _draggableView: CHDraggableView!
    
    var _draggingCoordinator : CHDraggingCoordinator!
    
    var draggableView: CHDraggableView! {
        get {
            return _draggableView
        }
    }
    
    private var isNotificationRegistered: Bool = false
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        application.applicationIconBadgeNumber = 0
        
        let config = UAConfig.defaultConfig()
        UAirship.takeOff(config)
        UAPush.shared().userNotificationTypes = (.Badge | .Sound | .Alert)
        UAPush.shared().userPushNotificationsEnabled = true
        
        switch kTHGamesServerMode {
        case .Staging:
            println("Current build points to Staging Server.\n")
        case .Prod:
            println("Current build points to Production Server.\n")
        }
        
        playMusic(kTHDefaultSong)
        
        self.registerLoginNotification()
        
        return true
    }

    func autoLogin(force: Bool = false) {
        if !force {
            if loginOnce == true { return }
            loginOnce = true
        }
        
        if let credential = NetworkClient.sharedClient.credentials {
            var retry = false
            var hud = JGProgressHUD.progressHUDWithDefaultStyle { [unowned self] HUD in
                if retry {
                    self.autoLogin(force: true)
                    HUD.dismiss()
                    retry = false
                }
            }
            
            hud.textLabel.text = "Logging in..."
            hud.showInWindow()
            
            NetworkClient.sharedClient.loginUserWithFacebookAuth(credential, loginSuccessHandler: {
                [unowned self] user in
                hud.dismissAnimated(true)
                }) { //error handler
                    [unowned self] error in
                    hud.textLabel.font = UIFont(name: "AvenirNext-Medium", size: 15)
                    if error.code == -1009 {
                        hud.layoutChangeAnimationDuration = 1.0
                        hud.indicatorView = JGProgressHUDErrorIndicatorView()
                        hud.textLabel.text = "Network connection lost. Please tap to retry."
                        
                        retry = true
                        
                        let animation = CABasicAnimation(keyPath: "shadowOpacity")
                        animation.fromValue = NSNumber(float: 0.0)
                        animation.toValue = NSNumber(float: 8.0)
                        animation.repeatCount = 1e50
                        animation.autoreverses = true
                        animation.duration = 1
                        
                        hud.HUDView.layer.shadowColor = UIColor.redColor().CGColor
                        hud.HUDView.layer.shadowOffset = CGSizeZero
                        hud.HUDView.layer.shadowOpacity = 0.0
                        hud.HUDView.layer.shadowRadius = 8.0
                        
                        hud.HUDView.layer.addAnimation(animation, forKey:"glow")
                    } else {
                        hud.textLabel.text = error.description
                        hud.dismissAfterDelay(3, animated: true)
                    }
            }
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        musicPlayer.stop()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        musicPlayer.stop()
        self.unregisterOtherNotification()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        musicPlayer.play()
        self.registerOtherNotification()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        musicPlayer.play()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

//    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String, annotation: AnyObject?) -> Bool {
//        return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
//    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        if let token = NetworkClient.sharedClient._device_token {
            if !(NetworkClient.sharedClient._device_token == deviceToken.deviceTokenString()) {
                NetworkClient.sharedClient._device_token = deviceToken.deviceTokenString()
                NetworkClient.sharedClient.updateDeviceToken(deviceToken.deviceTokenString(), errorHandler: {error in
                    debugPrintln(error.description)
                    }) { }
            }
        } else {
            NetworkClient.sharedClient._device_token = deviceToken.deviceTokenString()
            NetworkClient.sharedClient.updateDeviceToken(deviceToken.deviceTokenString(), errorHandler: {error in
                debugPrintln(error.description)
                }) { }
        }
        autoLogin()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        debugPrintln("Fail to register for push notification: \(error)")
    }
    
//    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
//        application.registerForRemoteNotifications()
//    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        //TODO: Implement
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
        
        if let d = _draggableView {
            self.window?.addSubview(_draggableView)
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
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "notificationHeadViewToggle", name: kTHGameNotificationHeadNotificationToggleKey, object: nil)
            self.isNotificationRegistered = true
        }
    }
    
    func unregisterOtherNotification(){
        if self.isNotificationRegistered {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: kTHGameLogoutNotificationKey, object: nil)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: kTHGameNotificationHeadNotificationToggleKey, object: nil)
            self.isNotificationRegistered = false
        }
    }
    
    func userDidLogout(notification:NSNotification){
        self.window?.rootViewController = UIStoryboard.loginStoryboard().instantiateInitialViewController() as? UIViewController
        self.unregisterOtherNotification()
        self.registerLoginNotification()
        
        self.loggedIn = false
    }
    
    func notificationHeadViewToggle(){
        self._draggableView.hideWithAnimation(kTHNotificationHeadOn)
    }
    
    private func setupNotificationHead(){
        let window = self.window!
        _draggableView = CHDraggableView(image: UIImage(named: "NotificationHeadImage"))
        _draggableView.tag = 1
        _draggingCoordinator = CHDraggingCoordinator(window: window, draggableViewBounds: _draggableView.bounds)
        _draggingCoordinator.delegate = self
        _draggingCoordinator.snappingEdge = CHSnappingEdgeBoth
        _draggableView.delegate = _draggingCoordinator
        _draggableView.hidden = !kTHNotificationHeadOn
    }
    
    func draggingCoordinator(coordinator: CHDraggingCoordinator!, viewControllerForDraggableView draggableView: CHDraggableView!) -> UIViewController! {
        let controller = UIStoryboard.inAppNotificationStoryboard().instantiateViewControllerWithIdentifier("InAppNotificationTableViewController") as? UIViewController
        return controller
    }
    
}

