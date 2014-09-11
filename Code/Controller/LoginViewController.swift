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
        
        var hud = JGProgressHUD.progressHUDWithCustomisedStyleInView(self.view)
        hud.indicatorView = nil
        
        hud.textLabel.text = "Logging in..."
        
        NetworkClient.sharedClient.loginUserWithFacebookAuth(FBSession.activeSession().accessTokenData.accessToken) { user in
            hud.dismissAfterDelay(1.5, animated: true)
        }
    }
}