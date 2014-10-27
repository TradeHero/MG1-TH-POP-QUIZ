//
//  FriendsViewController.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/13/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class FriendsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, FriendsChallengeCellTableViewCellDelegate, UISearchBarDelegate, StaffChallengeCellTableViewCellDelegate {
    
    private var THStaffList = [StaffUser]()
    
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
        self.tableView.registerNib(UINib(nibName: "StaffChallengeCellTableViewCell", bundle: nil), forCellReuseIdentifier: kTHStaffChallengeCellTableViewCellIdentifier)
        self.searchBar.placeholder = "Search friends"
        self.searchBar.text = ""
        self.tableView.tableHeaderView = self.searchBar
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 53
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.showNavigationBar()
        self.loadStaff {
//            self.loadFriends()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func loadStaff(completionHandler:()->()){
        var hud = JGProgressHUD.progressHUDWithCustomisedStyleInView(self.view)
        self.THStaffList.removeAll(keepCapacity: true)
        
        self.tableView.reloadData()
        let object = EGOCache.globalCache().objectForKey(kTHStaffUserCacheStoreKey)
        
        if !THCache.objectExistForCacheKey(kTHStaffUserCacheStoreKey) {
            debugPrintln("Nothing cached.")
            hud.textLabel.text = "Just a sec.."
            NetworkClient.sharedClient.fetchStaffList() {
                [unowned self] in
                hud.dismissAnimated(true)
                THCache.saveStaffListToCache($0)
                self.THStaffList = $0.filter {$0.userId != self.user.userId}
                self.tableView.reloadData()
                completionHandler()
            }
            return
        }
        
        var cachedStaff = THCache.getStaffListFromCache().filter {[unowned self] in $0.userId != self.user.userId}
        self.THStaffList = cachedStaff
        self.tableView.reloadData()
        completionHandler()
        
        hud.dismissAnimated(true)
    }
    
    private func loadFriends() {
        var hud = JGProgressHUD.progressHUDWithCustomisedStyleInView(self.view)
        self.FBFriendList.removeAll(keepCapacity: true)
        self.THFriendList.removeAll(keepCapacity: true)
        
        self.tableView.reloadData()
        
        let loadCompleteHandler:((fbFriends: [THUserFriend], thFriends:[THUserFriend]) -> ()) = {
            [unowned self] in
            self.FBFriendList = $0
            self.THFriendList = $1
            self.tableView.reloadData()
        }
        
        if !THCache.objectExistForCacheKey(kTHUserFriendsCacheStoreKey) {
            debugPrintln("Nothing cached.")
            hud.textLabel.text = "Retrieving friends..."
            NetworkClient.sharedClient.fetchFriendListForUser(self.user.userId, errorHandler: nil) {
                [unowned self] in
                hud.dismissAnimated(true)
                THCache.saveFriendsListToCache($0.facebookFriends, tradeheroFriends: $0.tradeheroFriends)
                loadCompleteHandler(fbFriends: $0.facebookFriends, thFriends: $0.tradeheroFriends)
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
            return THStaffList.count
        case 2:
            return THFriendList.count
        case 1:
            return FBFriendList.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        switch indexPath.section {
        case 0:
            var cell = tableView.dequeueReusableCellWithIdentifier(kTHStaffChallengeCellTableViewCellIdentifier, forIndexPath: indexPath) as StaffChallengeCellTableViewCell
            let staffUser = THStaffList[indexPath.row]
            cell.bindStaffUser(staffUser)
            cell.layoutIfNeeded()
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            cell.delegate = self
            return cell
        case 2:
            var cell = tableView.dequeueReusableCellWithIdentifier(kTHFriendsChallengeCellTableViewCellIdentifier, forIndexPath: indexPath) as FriendsChallengeCellTableViewCell
            let friendUser = THFriendList[indexPath.row]
            cell.bindFriendUser(friendUser, index: indexPath.row)
            cell.layoutIfNeeded()
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            cell.delegate = self
            return cell
        case 1:
            var cell = tableView.dequeueReusableCellWithIdentifier(kTHFriendsChallengeCellTableViewCellIdentifier, forIndexPath: indexPath) as FriendsChallengeCellTableViewCell
            let friendUser = FBFriendList[indexPath.row]
            cell.bindFriendUser(friendUser, index: indexPath.row)
            cell.layoutIfNeeded()
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            cell.delegate = self
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    
    
    //MARK:- UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 53
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            if THStaffList.count == 0 {
                return nil
            }
            return self.createTradeHeroStaffTableSectionHeaderView()
        case 2:
            if FBFriendList.count == 0 {
                return nil
            }
            return self.createFacebookFriendsTableSectionHeaderView()

        case 1:
            if THFriendList.count == 0 {
                return nil
            }
            return self.createTradeHeroFriendsTableSectionHeaderView()
                default:
            return nil
        }
    }
    
    func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            if THStaffList.count == 0 {
                return 0
            }
            return 25
        case 2:
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
        NetworkClient.sharedClient.createChallenge(opponentId: userID) {
            [unowned self] in
            if let g = $0 {
                hud.dismissAnimated(true)
                let vc = UIStoryboard.quizStoryboard().instantiateViewControllerWithIdentifier("GameLoadingSceneViewController") as GameLoadingSceneViewController
                vc.bindGame($0)
                self.navigationController?.pushViewController(vc, animated: true)
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
    
    func staffChallengeCellTableViewCell(cell: StaffChallengeCellTableViewCell, didTapChallengeWithStaffUser userId: Int) {
        var hud = JGProgressHUD.progressHUDWithCustomisedStyleInView(self.view)
        hud.textLabel.text = "Creating challenge..."
        hud.detailTextLabel.text = "Creating game with user.."
        NetworkClient.sharedClient.createChallenge(opponentId: userId) {
            [unowned self] in
            if let g = $0 {
                hud.dismissAnimated(true)
                let vc = UIStoryboard.quizStoryboard().instantiateViewControllerWithIdentifier("GameLoadingSceneViewController") as GameLoadingSceneViewController
                vc.bindGame($0)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }

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
    
    private func createTradeHeroStaffTableSectionHeaderView() -> UIView {
        var headerView = UIView(frame: CGRectMake(0, 0, 286, 22))
        var logoView = UIImageView(frame: CGRectMake(2, 2, 19, 19))
        logoView.image = UIImage(named: "TradeHeroFriendsBullIcon")
        headerView.addSubview(logoView)
        
        var labelView = UILabel(frame: CGRectMake(28, 1, 142, 21))
        labelView.text = "TradeHero's Staff"
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
