//
//  LoginViewController.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/5/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import Views

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.loginView.delegate = self
//        self.loginView.readPermissions = ["public_profile"]
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func loginButtonClicked(sender: AnyObject) {
       let req = Alamofire.request(.GET, THMiniGameAPIBaseURL + "/question", parameters: nil, encoding:.URL)
        req.response{(request, response, data, error) in
            println(request)
            println(response)
            println(error)
        }
        NetworkClient.loginUserWithFacebook()
        
    }
    
    
}
