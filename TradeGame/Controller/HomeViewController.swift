//
//  HomeViewController.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/5/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HomeTurnChallengesTableViewCellDelegate {

    @IBOutlet weak var avatarView: AvatarRoundedView!
    @IBOutlet weak var fullNameView: UILabel!
    @IBOutlet weak var rankView: UILabel!
    
    private var user: THUser
    
    private lazy var noOpenChallenge:Bool = {
        return true
    }()
    required init(coder aDecoder: NSCoder) {
        self.user = NetworkClient.sharedClient.authenticatedUser
        super.init(coder: aDecoder)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        self.setNavigationTintColor(UIColor(hex: 0x303030), buttonColor: UIColor(hex: 0xffffff))
        self.navigationItem.title = "Home"
        self.navigationController.navigationBar.titleTextAttributes = [ NSFontAttributeName : UIFont(name: "AvenirNext-Medium", size: 18), NSForegroundColorAttributeName : UIColor.whiteColor(), NSBackgroundColorAttributeName : UIColor.whiteColor()]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "FriendsViewPushSegue" {
            let vc = segue.destinationViewController as FriendsViewController
            vc.user = self.user
        }
        
    }
    
    //MARK:- Actions
    @IBAction func logoutClicked(sender: AnyObject) {
        FBSession.activeSession().closeAndClearTokenInformation()
        NetworkClient.sharedClient.logout()
        NSNotificationCenter.defaultCenter().postNotificationName(kTHGameLogoutNotificationKey, object: self, userInfo:nil)
    }
    
    //MARK:- Private functions
    private func setupSubviews() {
        NetworkClient.fetchImageFromURLString(user.pictureURL, progressHandler: nil)  {
            (image: UIImage!, error:NSError!) in
            if image != nil {
                self.avatarView.image = image
            }
        }
        self.fullNameView.text = user.displayName
        //        self.rankView.text =
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        return nil
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        switch section {
        case 0:
            if noOpenChallenge {
                return createHeaderViewForEmptyTurn()
            }
            return createHeaderView("Your turn", numberOfGames: 0)
        case 1:
            return createHeaderView("Their turn", numberOfGames: 0)
        default:
            return nil
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            if noOpenChallenge {
                return 119
            }
            return 25
        case 1:
            return 25
        default:
            return 0
        }
    }
    
    private func createHeaderViewForEmptyTurn() -> UIView {
        var headerView = UIView(frame: CGRectMake(0, 0, 286, 119))
        var logoView = UIImageView(frame: CGRectMake(119, 23, 51, 51))
        logoView.image = UIImage(named: "NoChallengeEmoticon")
        headerView.addSubview(logoView)
        
        var leftLabelView = UILabel(frame: CGRectMake(4, 4, 72, 21))
        leftLabelView.text = "Your Turn"
        leftLabelView.font = UIFont(name: "AvenirNext-Medium", size: 15)
        leftLabelView.textColor = UIColor.whiteColor()
        headerView.addSubview(leftLabelView)
        
        var rightLabelView = UILabel(frame: CGRectMake(213, 4, 65, 21))
        rightLabelView.text = "0 games"
        rightLabelView.textAlignment = .Right
        rightLabelView.font = UIFont(name: "AvenirNext-Medium", size: 15)
        rightLabelView.textColor = UIColor.whiteColor()
        headerView.addSubview(rightLabelView)
        
        var textLabel = UILabel(frame: CGRectMake(40, 81, 208, 38))
        textLabel.text = "No pending game. \r Why don’t you start a challenge?"
        textLabel.numberOfLines = 2
        textLabel.textAlignment = .Center
        textLabel.font = UIFont(name: "AvenirNext-Regular", size: 13)
        textLabel.textColor = UIColor.whiteColor()
        textLabel.lineBreakMode = .ByWordWrapping
        headerView.addSubview(textLabel)
        return headerView
    }
    
    private func createHeaderView(title:String, numberOfGames:Int) -> UIView {
        var headerView = UIView(frame: CGRectMake(0, 0, 286, 25))
        var leftLabelView = UILabel(frame: CGRectMake(4, 4, 72, 21))
        leftLabelView.text = title
        leftLabelView.font = UIFont(name: "AvenirNext-Medium", size: 15)
        leftLabelView.textColor = UIColor.whiteColor()
        headerView.addSubview(leftLabelView)
        
        var rightLabelView = UILabel(frame: CGRectMake(213, 4, 65, 21))
        rightLabelView.text = "\(numberOfGames) games"
        rightLabelView.textAlignment = .Right
        rightLabelView.font = UIFont(name: "AvenirNext-Medium", size: 15)
        rightLabelView.textColor = UIColor.whiteColor()
        headerView.addSubview(rightLabelView)
        return headerView
    }
    
    func homeTurnChallengesCell(cell: HomeTurnChallengesTableViewCell, didTapAcceptChallenge challengeId: Int) {
        
    }
}
