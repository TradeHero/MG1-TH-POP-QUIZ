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

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
    
    @IBAction func loginButtonClicked(sender: AnyObject) {
        let username: String = emailField.text
        let password: String = passwordField.text
        
        NetworkClient.sharedClient.loginUserWithBasicAuth(username, password: password) {
            (user: THUser?) -> () in
            if let loginUser = user {
                let vc = self.storyboard.instantiateViewControllerWithIdentifier("ChallengeViewController") as ChallengeViewController
                self.presentViewController(vc, animated: true, completion: nil)
                
            } else {
                UIAlertView(title: "Login failed", message: "Please retype your login credentials", delegate: nil, cancelButtonTitle: "Dismiss").show()
            }
        }
    }
}
//