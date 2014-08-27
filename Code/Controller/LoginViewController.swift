//
//  LoginViewController.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/5/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBLoginViewDelegate {

    @IBOutlet private weak var emailField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!
    @IBOutlet private weak var fbLoginView: FBLoginView!
    private var fbFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidDisappear(animated: Bool) {
        fbFlag = false
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        
        if !fbFlag {
            fbFlag = true
        }else {
            return
        }
        
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Logging in..."
        hud.labelFont = UIFont(name: "AvenirNext-Medium", size: 15)
        weak var weakSelf = self
        NetworkClient.sharedClient.loginUserWithFacebookAuth(FBSession.activeSession().accessTokenData.accessToken, errorHandler: { error in
                hud.mode = MBProgressHUDModeText
                hud.labelText = "Login error: \(error.description)"
                hud.hide(true, afterDelay: 1.5)
            }) {
             user in
                if user == nil {
                    hud.mode = MBProgressHUDModeText
                    hud.labelText = "Login failed"
                    hud.hide(true, afterDelay: 1.5)
                }
        }
    }
}