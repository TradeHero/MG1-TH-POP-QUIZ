//
//  LoginViewController.swift
//  TH-PopQuiz
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func facebookTapped(sender: AnyObject) {
        var hud = JGProgressHUD.progressHUDWithCustomisedStyleInView(self.view)
        let facebookTypeAccount = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierFacebook)
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView(HUDStyle:hud.style)
        hud.textLabel.text = "Logging in..."
        accountStore.requestAccessToAccountsWithType(facebookTypeAccount, options: [ACFacebookAppIdKey : kTHFacebookAppID]) { [unowned self] (granted, error) -> Void in
            
            if granted {
                if let accts = self.accountStore.accountsWithAccountType(facebookTypeAccount) as? [ACAccount] {
                    if accts.count > 1 {
                        hud.textLabel.font = UIFont(name: "AvenirNext-Medium", size: 15)
                        hud.textLabel.text = "You have more than one Facebook account linked, please make sure that you only have on Facebook account connected."
                    }
                    self.facebookAccount = accts.last
                    if let fb = self.facebookAccount {
                        let accessToken = self.facebookAccount.credential.oauthToken
                        NetworkClient.sharedClient.loginUserWithFacebookAuth(accessToken, loginSuccessHandler: {user in
                            //succeed
                            }) {
                            //failure
                            hud.textLabel.font = UIFont(name: "AvenirNext-Medium", size: 15)
                            hud.textLabel.text = "\($0)"
                        }
                    } else {
                        hud.textLabel.font = UIFont(name: "AvenirNext-Medium", size: 15)
                        hud.textLabel.text = "Facebook token does not exist."
                    }
                }
            } else {
                if let e = error {
                    hud.textLabel.font = UIFont(name: "AvenirNext-Medium", size: 15)
                    hud.textLabel.text = "Please login to Facebook from Settings >> Facebook, you should only have one Facebook account logged in at one time."
                    hud.dismissAfterDelay(5, animated: true)
                }
            }
        }
        
    }
}