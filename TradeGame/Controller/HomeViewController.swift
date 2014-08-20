//
//  HomeViewController.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/5/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var avatarView: AvatarRoundedView!
    @IBOutlet weak var fullNameView: UILabel!
    @IBOutlet weak var rankView: UILabel!
    
    private var user: THUser {
        didSet{
            setupSubviews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        self.setNavigationTintColor(UIColor(hex: 0x303030), buttonColor: UIColor(hex: 0x7AB800))
        self.navigationController.navigationBar.setBackgroundImage(UIImage(""), forBarMetrics: .Default)
    }
    
    @IBAction func logoutClicked(sender: AnyObject) {
        FBSession.activeSession().closeAndClearTokenInformation()
        NetworkClient.sharedClient.logout()
        NSNotificationCenter.defaultCenter().postNotificationName(kTHGameLogoutNotificationKey, object: self, userInfo:nil)
    }
    
    func setupSubviews() {
        NetworkClient.fetchImageFromURLString(user.pictureURL, progressHandler: nil)  {
                (image: UIImage!, error:NSError!) in
                if image != nil {
                    self.avatarView.image = image
                }
        }
        self.fullNameView.text = user.displayName
//        self.rankView.text = 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init(coder aDecoder: NSCoder) {
        self.user = NetworkClient.sharedClient.authenticatedUser
        super.init(coder: aDecoder)
    }
    
    @IBAction func loadFriends(sender: AnyObject) {
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Loading friends..."
        NetworkClient.sharedClient.fetchFriendListForUser(self.user.userId, errorHandler: nil, completionHandler: { friends in
            hud.hide(true)
            let vc = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier("FriendsViewController") as FriendsViewController
            vc.friendsList = friends
            self.navigationController.pushViewController(vc, animated: true)
            
        })
    }
}
