//
//  ChallengeViewController.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/5/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class ChallengeViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var avatarView: AvatarRoundedView!
    @IBOutlet weak var fullNameView: UILabel!
    @IBOutlet weak var rankView: UILabel!

    var progressView: OverlayProgressView!
    
    private var user: THUser {
        didSet{
            setupSubviews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        self.navigationItem.hidesBackButton = true
    }
    
    @IBAction func logoutClicked(sender: AnyObject) {
        FBSession.activeSession().closeAndClearTokenInformation()
        NetworkClient.sharedClient.logout()
        self.navigationController.popViewControllerAnimated(true)
    }
    
    func setupSubviews() {
//        self.progressView = OverlayProgressView(frame: self.avatarView.bounds)
//        self.avatarView.addSubview(self.progressView)
//        self.progressView?.displayOperationWillTriggerAnimation()
        NetworkClient.fetchImageFromURLString(user.pictureURL, progressHandler: {
            (current:Int, expected:Int) -> Void in
//            let ratio:CGFloat = CGFloat(current)/CGFloat(expected)
//            if ratio >= 1 {
//                self.progressView?.displayOperationDidFinishAnimation()
//                let delay = self.progressView?.stateChangeAnimationDuration
//                let poptime = dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(delay!) * NSEC_PER_SEC))
//                dispatch_after(poptime, dispatch_get_main_queue(), {() -> Void in
//                    self.progressView?.progress = 0
//                    self.progressView?.hidden = true
//                })
//            } else {
//                self.progressView?.progress = ratio
//            }
            })  {
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
    
    required init(coder aDecoder: NSCoder!) {
        self.user = NetworkClient.sharedClient.authenticatedUser
        super.init(coder: aDecoder)
    }
    
    @IBAction func loadFriends(sender: AnyObject) {
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Loading friends..."
        NetworkClient.sharedClient.fetchFriendListForUser(self.user.userId, errorHandler: nil, completionHandler: { friends in
            hud.hide(true)
            for friend in friends {
                println(friend)
            }
            let vc = self.storyboard.instantiateViewControllerWithIdentifier("FriendsViewController") as FriendsViewController
            vc.friendsList = friends
            self.navigationController.pushViewController(vc, animated: true)
            
        })
    }
    
    @IBAction func createQuickplayGame(sender: AnyObject) {
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Creating quick game..."
        NetworkClient.sharedClient.createQuickGame() {
            createdGame in
            if let game = createdGame {
                println("GAME CREATED: \n\(game)")
                hud.hide(true, afterDelay: 0.5)
            }
        }
        
        
    }
}
