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
    
    lazy var user: THUser = THUser()
    @IBOutlet weak var friendsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController.navigationBarHidden = false
        self.navigationItem.title = "Friend List"
        self.friendsTableView.registerNib(UINib(nibName: "FriendsChallengeCellTableViewCell", bundle: nil), forCellReuseIdentifier: kTHFriendsChallengeCellTableViewCellIdentifier)
        self.loadFriends()
    }
    
    @IBAction func backAction(sender: AnyObject) {
        self.navigationController.popViewControllerAnimated(true)
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
            if THFriendList.count == 0 {
                return nil
            }
            return self.createTradeHeroFriendsTableSectionHeaderView()
        case 1:
            if FBFriendList.count == 0 {
                return nil
            }
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
    
    func loadFriends() {
        self.FBFriendList.removeAll(keepCapacity: true)
        self.THFriendList.removeAll(keepCapacity: true)
        
        self.friendsTableView.reloadData()
        
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.removeFromSuperViewOnHide = true

        TMCache.sharedCache().objectForKey(kTHUserFriendsCacheStoreKey, block: { (cache, string, object) -> Void in
            let i = 0
            let kFBFriendsDictionaryKey = "FBFriendsDictionaryKey"
            let kTHFriendsDictionaryKey = "THFriendsDictionaryKey"
            if object == nil {
                debugPrintln("Nothing cached.")
                hud.labelText = "Retrieving friends..."
                NetworkClient.sharedClient.fetchFriendListForUser(self.user.userId, errorHandler: nil, completionHandler: { friendsTuple in
                    hud.removeFromSuperview()
                    let fbF = friendsTuple.fbFriends
                    let thF = friendsTuple.thFriends
                    let dict = [kFBFriendsDictionaryKey: fbF, kTHFriendsDictionaryKey: thF]
                    TMCache.sharedCache().setObject(dict, forKey: kTHUserFriendsCacheStoreKey)
                    debugPrintln("\(friendsTuple.fbFriends.count + friendsTuple.thFriends.count) friends cached.")
                    self.THFriendList = thF
                    self.FBFriendList = fbF
                    self.friendsTableView.reloadData()
                })
                return
            }
            
            hud.labelText = "Loading friends..."
            var cachedFriends = object as [String : [THUserFriend]]
            
            if let cFBFrnd = cachedFriends[kFBFriendsDictionaryKey] {
                self.FBFriendList = cFBFrnd
            }
            
            if let cTHFrnd = cachedFriends[kTHFriendsDictionaryKey] {
                self.THFriendList = cTHFrnd
            }
            
            debugPrintln("Retrieved \(self.FBFriendList.count + self.THFriendList.count) friend(s) from cache.")
            
            self.friendsTableView.reloadData()
            hud.removeFromSuperview()
            return
        })
        
    }
}
