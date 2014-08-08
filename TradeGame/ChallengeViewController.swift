//
//  ChallengeViewController.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/5/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import Models
import Views

class ChallengeViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var fullNameView: UILabel!
    @IBOutlet weak var rankView: UILabel!
    
    @IBOutlet weak var contentScrollView: UIScrollView!
    
    var progressView: OverlayProgressView? = nil
    
    private weak var user: THUser?
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
    
    func setupSubviews() {
        self.progressView = OverlayProgressView(frame: self.avatarView.bounds)
        self.avatarView.addSubview(self.progressView!)
        self.progressView?.displayOperationWillTriggerAnimation()
        NetworkClient.fetchImageFromURLString((user?.pictureURL)!, progressHandler: {
            (current:Int, expected:Int) -> Void in
            let ratio:CGFloat = CGFloat(current)/CGFloat(expected)
            if ratio >= 1 {
                self.progressView?.displayOperationDidFinishAnimation()
                let delay = self.progressView?.stateChangeAnimationDuration
                let poptime = dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(delay!) * NSEC_PER_SEC))
                dispatch_after(poptime, dispatch_get_main_queue(), {() -> Void in
                    self.progressView?.progress = 0
                    self.progressView?.hidden = true
                })
            } else {
                self.progressView?.progress = ratio
            }
            })  {
                (image: UIImage!, error:NSError!) in
                if image != nil {
                    self.avatarView.image = image
                }
                
        }
        self.fullNameView.text = user?.fullName
        self.rankView.text = user?.gamePortfolio.rank
        
        self.contentScrollView.delegate = self
        let bigView = UIView(frame: CGRectMake(0, 0, 320, 1100))
        contentScrollView.addSubview(bigView)
        contentScrollView.contentSize = bigView.bounds.size
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        user = NetworkClient.sharedClient.authenticatedUser
    }
    
    
}
