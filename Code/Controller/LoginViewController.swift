//
//  LoginViewController.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/5/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import Social
import Accounts

class LoginViewController: UIViewController {
    
    private var accountStore = ACAccountStore()
    
    private var facebookAccount: ACAccount!
    
    private var fbFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.autoLogin()
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
    
    func autoLogin() {
        var hud = JGProgressHUD.progressHUDWithCustomisedStyleInView(self.view)
        hud.indicatorView = nil
        hud.textLabel.text = "Logging in..."
        if let credential = NetworkClient.sharedClient.credentials {
            NetworkClient.sharedClient.loginUserWithFacebookAuth(credential) {
                user in
                hud.dismissAfterDelay(1.5, animated: true)
            }
        }
    }
  
    @IBAction func facebookTapped(sender: AnyObject) {
        var hud = JGProgressHUD.progressHUDWithCustomisedStyleInView(self.view)
        let facebookTypeAccount = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierFacebook)
        hud.indicatorView = nil
        hud.textLabel.text = "Logging in..."
        accountStore.requestAccessToAccountsWithType(facebookTypeAccount, options: [ACFacebookAppIdKey : kTHFacebookAppID]) { [unowned self] (granted, error) -> Void in
            if hud != nil { hud.dismissAfterDelay(1.5, animated: true) }
            if granted {
                if let accts = self.accountStore.accountsWithAccountType(facebookTypeAccount) as? [ACAccount] {
                    self.facebookAccount = accts.last
                    let accessToken = self.facebookAccount.credential.oauthToken
                    NetworkClient.sharedClient.loginUserWithFacebookAuth(accessToken) { user in
                    }
                }
            } else {
                if let e = error {
                    hud.textLabel.font = UIFont(name: "AvenirNext-Medium", size: 15)
                    hud.textLabel.text = "Please login to Facebook from Settings >> Facebook."
                    hud.dismissAfterDelay(2.5, animated: true)
                }
            }
        }

    }
    }