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
import JGProgressHUD
import FacebookSDK

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
        super.init(coder: aDecoder)!
    }

    @IBAction func facebookTapped(sender: AnyObject) {
        var hud = JGProgressHUD.progressHUDWithDefaultStyle()
        hud.showInWindow()
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView(HUDStyle: hud.style)
        hud.textLabel.text = "Logging in..."

        FacebookService.sharedService.FacebookConnectWithSDK {
            (session, error) -> () in
            if let e = error {

            }

            let accessToken = session.accessTokenData.accessToken;
            NetworkClient.sharedClient.loginUserWithFacebookAuth(accessToken, loginSuccessHandler: {
                user in
                //succeed
            }) {
                //failure
                hud.textLabel.font = UIFont(name: "AvenirNext-Medium", size: 15)
                hud.textLabel.text = "\($0)"
            }
        }
    }

}