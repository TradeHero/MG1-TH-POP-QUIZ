//
//  LoginViewController.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/5/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBLoginViewDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var fbLoginView: FBLoginView!
    var fbFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
        self.setNavigationTintColor(UIColor(hex: 0x303030), buttonColor: UIColor(hex: 0xffffff))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidDisappear(animated: Bool) {
        println("reset flag")
        fbFlag = false
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        println(fbFlag)
        if !fbFlag {
            fbFlag = true
        }else {
            return
        }
        
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Logging in..."
        
        weak var weakSelf = self
        NetworkClient.sharedClient.loginUserWithFacebookAuth(FBSession.activeSession().accessTokenData.accessToken, errorHandler: { error in
                hud.mode = MBProgressHUDModeText
                hud.labelText = "Login error: \(error.description)"
                hud.hide(true, afterDelay: 1.5)
            }) {
             user in
            var strongSelf = weakSelf!
            if let loginUser = user {
                hud.hide(true)
                let vc = strongSelf.storyboard.instantiateViewControllerWithIdentifier("ChallengeViewController") as ChallengeViewController
                strongSelf.navigationController.pushViewController(vc, animated: true)
            } else {
                hud.mode = MBProgressHUDModeText
                hud.labelText = "Login failed"
                hud.hide(true, afterDelay: 1.5)
            }
        }
    }
}