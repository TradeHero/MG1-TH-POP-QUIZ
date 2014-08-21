//
//  FriendsViewController.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/13/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class FriendsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, FriendsChallengeCellTableViewCellDelegate {

    var friendsList: [THUserFriend] = []
    
    var THFriendList: [THUserFriend] = []
    
    var FBFriendList: [THUserFriend] = []
    
    @IBOutlet weak var friendsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController.navigationBarHidden = false
        self.navigationItem.title = "Friend List"
        let view = UIView(frame: CGRectMake(0, 0, 200, 100))
        self.friendsTableView.backgroundColor = UIColor.clearColor()
        self.friendsTableView.delegate = self
        self.friendsTableView.dataSource = self
        self.friendsTableView.registerNib(UINib(nibName: "FriendsChallengeCellTableViewCell", bundle: nil), forCellReuseIdentifier: kTHFriendsChallengeCellTableViewCellIdentifier)
        var backButton = UIButton(frame: CGRectMake(0, 0, 15.5, 17))
        backButton.setBackgroundImage(UIImage(named: "BackButtonImage"), forState: UIControlState.Normal)
        backButton.addTarget(self.navigationController, action: "popViewControllerAnimated:",  forControlEvents: UIControlEvents.TouchUpInside)
        var barButtonItem = UIBarButtonItem(customView: backButton)
        barButtonItem.width = 15.5
        self.navigationItem.leftBarButtonItem = barButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Data source
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return THFriendList.count
        case 1:
            return FBFriendList.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell: FriendsChallengeCellTableViewCell! = tableView.dequeueReusableCellWithIdentifier(kTHFriendsChallengeCellTableViewCellIdentifier, forIndexPath: indexPath) as FriendsChallengeCellTableViewCell
        
        switch indexPath.section {
        case 0:
            let friendUser = THFriendList[indexPath.row]
            cell.bindFriendUser(friendUser)
        case 1:
            let friendUser = FBFriendList[indexPath.row]
            cell.bindFriendUser(friendUser)
        default:
            return nil
        }

        cell.layoutIfNeeded()
        cell.delegate = self
        return cell
    }
   required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK:- Delegate
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 48.0
    }
    
    func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        switch section {
        case 0:
            return self.createTradeHeroFriendsTableSectionHeaderView()
        case 1:
            return self.createFacebookFriendsTableSectionHeaderView()
        default:
            return nil
        }
    }
    
    func createTradeHeroFriendsTableSectionHeaderView() -> UIView {
        var headerView = UIView(frame: CGRectMake(0, 0, 286, 22))
        var logoView = UIImageView(frame: CGRectMake(2, 2, 19, 19))
        logoView.image = UIImage(named: "TradeHeroFriendsBullIcon")
        headerView.addSubview(logoView)
        
        var labelView = UILabel(frame: CGRectMake(28, 1, 142, 21))
        labelView.text = "TradeHero's Friends"
        labelView.font = UIFont(name: "AvenirNext-Medium", size: 15)
        labelView.textColor = UIColor.whiteColor()
        headerView.addSubview(labelView)
        return headerView
    }
    
    func createFacebookFriendsTableSectionHeaderView() -> UIView {
        var headerView = UIView(frame: CGRectMake(0, 0, 286, 22))
        var logoView = UIImageView(frame: CGRectMake(2, 2, 19, 19))
        logoView.image = UIImage(named: "FacebookFriendsMiniIcon")
        headerView.addSubview(logoView)
        
        var labelView = UILabel(frame: CGRectMake(28, 1, 142, 21))
        labelView.text = "Facebook Friends"
        labelView.font = UIFont(name: "AvenirNext-Medium", size: 15)
        labelView.textColor = UIColor.whiteColor()
        headerView.addSubview(labelView)
        return headerView
    }
    
    func friendUserCell(cell: FriendsChallengeCellTableViewCell, didTapChallengeUser userID: Int) {
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Creating challenge..."
        
        weak var weakSelf = self
        NetworkClient.sharedClient.createChallenge(10, opponentId: userID, completionHandler: {
        game in
            var strongSelf = weakSelf!
            if let g = game {
                hud.mode = MBProgressHUDModeText
                hud.detailsLabelText = "Creating game with user.."
                println(game)
                let vc = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier("QuizViewController") as QuizViewController
                hud.mode = MBProgressHUDModeAnnularDeterminate
                
                vc.prepareGame(game, hud:hud) {
                    progress -> () in
                    var strongSelf = weakSelf!
                    hud.detailsLabelText = "Done fetching image."
                    hud.hide(true, afterDelay: 1)
                    strongSelf.presentViewController(vc, animated: true, completion: nil)
                }
            }
            
        })
        
    }
    
    func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func bindFriendList(allFriends: [THUserFriend]) {
        for friend in allFriends {
            if friend.userID == 0 {
                self.FBFriendList.append(friend)
            } else {
                self.THFriendList.append(friend)
            }
        }
    }
}
