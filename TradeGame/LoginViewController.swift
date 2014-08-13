//
//  LoginViewController.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/5/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import Views
import Models

class LoginViewController: UIViewController, FBLoginViewDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var fbLoginView: FBLoginView!
    
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
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        
        var pictureURL: String = "https://graph.facebook.com/\(user.objectID)/picture?height=1000&width=1000"
        
        let id = Int((user.objectID as NSString).intValue)
        
        NetworkClient.sharedClient.loginUserWithFacebookAuth(FBSession.activeSession().accessTokenData.accessToken) {
            (user: THUser?) -> () in
            if let loginUser = user {
                let vc = self.storyboard.instantiateViewControllerWithIdentifier("ChallengeViewController") as ChallengeViewController
                self.presentViewController(vc, animated: true, completion: nil)
                
            } else {
                UIAlertView(title: "Login failed", message: "Please re-enter your login credentials.", delegate: nil, cancelButtonTitle: "Dismiss").show()
            }
        }
    }
}