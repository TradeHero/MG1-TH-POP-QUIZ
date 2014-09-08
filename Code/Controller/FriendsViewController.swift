//
//  FriendsViewController.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/13/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class FriendsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, FriendsChallengeCellTableViewCellDelegate, UISearchBarDelegate {
    private let kFBFriendsDictionaryKey = "FBFriendsDictionaryKey"
    
    private let kTHFriendsDictionaryKey = "THFriendsDictionaryKey"
    
    private var THFriendList: [THUserFriend] = []
    
    private var FBFriendList: [THUserFriend] = []
    
    private var searchKey: String = ""
    
    private lazy var user: THUser = {
        return NetworkClient.sharedClient.authenticatedUser
        }()
    
    @IBOutlet private weak var friendsTableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    
    //MARK:- Init
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Friend List"
        self.friendsTableView.registerNib(UINib(nibName: "FriendsChallengeCellTableViewCell", bundle: nil), forCellReuseIdentifier: kTHFriendsChallengeCellTableViewCellIdentifier)
        self.searchBar.placeholder = "Search friends"
        self.searchBar.text = ""
        self.friendsTableView.tableHeaderView = self.searchBar
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.showNavigationBar()
        self.loadFriends()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func loadFriends() {
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.removeFromSuperViewOnHide = true
        hud.minShowTime = 0
        hud.labelFont = UIFont(name: "AvenirNext-Medium", size: 15)
        self.FBFriendList.removeAll(keepCapacity: true)
        self.THFriendList.removeAll(keepCapacity: true)
        
        self.friendsTableView.reloadData()
        
        weak var wself = self
        let loadCompleteHandler:((fbFriends: [THUserFriend], thFriends:[THUserFriend]) -> Void) = {
            var sself = wself!
            sself.FBFriendList = $0
            sself.THFriendList = $1
            sself.friendsTableView.reloadData()
        }
        
        let object = EGOCache.globalCache().objectForKey(kTHUserFriendsCacheStoreKey)
        
        if object == nil {
            debugPrintln("Nothing cached.")
            hud.labelText = "Retrieving friends..."
            NetworkClient.sharedClient.fetchFriendListForUser(self.user.userId, errorHandler: nil) {
                var sself = wself!
                hud.hide(false)
                let fbF = $0.fbFriends
                let thF = $0.thFriends
                let dict = [sself.kFBFriendsDictionaryKey: fbF, sself.kTHFriendsDictionaryKey: thF]
                EGOCache.globalCache().setObject(dict, forKey: kTHUserFriendsCacheStoreKey)
                debugPrintln("\($0.fbFriends.count + $0.thFriends.count) friends cached.")
                loadCompleteHandler(fbFriends: fbF, thFriends: thF)
            }
            return
        }
        
        hud.labelText = "Loading friends..."
        var cachedFriends = object as [String : [THUserFriend]]
        
        if let cFBFrnd = cachedFriends[kFBFriendsDictionaryKey] {
            if let cTHFrnd = cachedFriends[kTHFriendsDictionaryKey] {
                debugPrintln("Retrieved \(cFBFrnd.count + cTHFrnd.count) friend(s) from cache.")
                loadCompleteHandler(fbFriends: cFBFrnd, thFriends: cTHFrnd)
            }
        }
        
        hud.hide(false)
    }
    
    @IBAction func backAction(sender: AnyObject) {
        let dict = [self.kFBFriendsDictionaryKey: self.FBFriendList, kTHFriendsDictionaryKey: self.THFriendList]
        EGOCache.globalCache().setObject(dict, forKey: kTHUserFriendsCacheStoreKey)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK:- UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return THFriendList.count
        case 1:
            return FBFriendList.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(kTHFriendsChallengeCellTableViewCellIdentifier, forIndexPath: indexPath) as FriendsChallengeCellTableViewCell
        
        switch indexPath.section {
        case 0:
            let friendUser = THFriendList[indexPath.row]
            cell.bindFriendUser(friendUser, index: indexPath.row)
        case 1:
            let friendUser = FBFriendList[indexPath.row]
            cell.bindFriendUser(friendUser, index: indexPath.row)
        default:
            break
        }
        
        cell.layoutIfNeeded()
        cell.delegate = self
        return cell
    }
    
    
    
    //MARK:- UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 48.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
    
    func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            if THFriendList.count == 0 {
                return 0
            }
            return 25
        case 1:
            if FBFriendList.count == 0 {
                return 0
            }
            return 25
        default:
            return 0
        }
        
    }
    
    //MARK:- FriendsChallengeCellTableViewCellDelegate
    func friendUserCell(cell: FriendsChallengeCellTableViewCell, didTapChallengeUser userID: Int) {
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Creating challenge..."
        hud.labelFont = UIFont(name: "AvenirNext-Medium", size: 15)
        weak var weakSelf = self
        NetworkClient.sharedClient.createChallenge(opponentId: userID) {
            var strongSelf = weakSelf!
            if let g = $0 {
                hud.mode = MBProgressHUDModeText
                hud.detailsLabelText = "Creating game with user.."
                
                let vc = UIStoryboard.quizStoryboard().instantiateViewControllerWithIdentifier("GameLoadingSceneViewController") as GameLoadingSceneViewController
                vc.bindGame($0)
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func friendUserCell(cell: FriendsChallengeCellTableViewCell, didTapInviteUser facebookID: Int) {
        //TODO: invite user via fb
        var friendUser = FBFriendList[cell.index]
        friendUser.alreadyInvited = true
        cell.friendUser = friendUser
        FBFriendList[cell.index] = friendUser
    }
    
    //MARK:- Search bar delegate
    func searchBarShouldBeginEditing(searchBar: UISearchBar!) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar!) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar!) {
        if (searchBar.text.length <= 0) {
            return
        }
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar!) {
        searchBar.resignFirstResponder()
    }
    
    //MARK:- UI construct
    private func createTradeHeroFriendsTableSectionHeaderView() -> UIView {
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
    
    private func createFacebookFriendsTableSectionHeaderView() -> UIView {
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
}
