//
//  FriendsViewController.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/13/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class FriendsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, FriendsChallengeCellTableViewCellDelegate, UISearchBarDelegate {
    
    private var THFriendList = [THUserFriend]()
    
    private var FBFriendList = [THUserFriend]()
    
    private var searchKey: String = ""
    
    private lazy var user: THUser = {
        return NetworkClient.sharedClient.user
        }()
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    
    //MARK:- Init
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Friend List"
        self.tableView.registerNib(UINib(nibName: "FriendsChallengeCellTableViewCell", bundle: nil), forCellReuseIdentifier: kTHFriendsChallengeCellTableViewCellIdentifier)
        self.searchBar.placeholder = "Search friends"
        self.searchBar.text = ""
        self.tableView.tableHeaderView = self.searchBar
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 53
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
        var hud = JGProgressHUD.progressHUDWithCustomisedStyleInView(self.view)
        self.FBFriendList.removeAll(keepCapacity: true)
        self.THFriendList.removeAll(keepCapacity: true)
        
        self.tableView.reloadData()
        
        weak var wself = self
        
        let loadCompleteHandler:((fbFriends: [THUserFriend], thFriends:[THUserFriend]) -> ()) = {
            var sself = wself!
            sself.FBFriendList = $0
            sself.THFriendList = $1
            sself.tableView.reloadData()
        }
        
        let object = EGOCache.globalCache().objectForKey(kTHUserFriendsCacheStoreKey)
        
        if object == nil {
            debugPrintln("Nothing cached.")
            hud.textLabel.text = "Retrieving friends..."
            NetworkClient.sharedClient.fetchFriendListForUser(self.user.userId, errorHandler: nil) {
                var sself = wself!
                hud.dismissAnimated(true)
                THCache.saveFriendsListToCache($0.fbFriends, tradeheroFriends: $0.thFriends)
                loadCompleteHandler(fbFriends: $0.fbFriends, thFriends: $0.thFriends)
            }
            return
        }
        
        hud.textLabel.text = "Loading friends..."
        
        var cacheFriends = THCache.getFriendsListFromCache()
        loadCompleteHandler(fbFriends: cacheFriends.facebookFriends, thFriends: cacheFriends.tradeheroFriends)
        
        hud.dismissAnimated(true)
    }
    
    @IBAction func backAction(sender: AnyObject) {
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
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        cell.delegate = self
        return cell
    }
    
    
    
    //MARK:- UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 53
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
        var hud = JGProgressHUD.progressHUDWithCustomisedStyleInView(self.view)
        hud.textLabel.text = "Creating challenge..."
        hud.detailTextLabel.text = "Creating game with user.."
        weak var weakSelf = self
        NetworkClient.sharedClient.createChallenge(opponentId: userID) {
            var strongSelf = weakSelf!
            if let g = $0 {
                hud.dismissAnimated(true)
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
