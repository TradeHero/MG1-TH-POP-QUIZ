//
//  FriendsViewController.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 8/13/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import JGProgressHUD
import EGOCache
import FacebookSDK
import Argo

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FriendsChallengeCellTableViewCellDelegate, StaffChallengeCellTableViewCellDelegate {

    private var THStaffList = [StaffUser]()

    private var THFriendList = [UserFriend]()

    private var FBFriendList = [UserFriend]()

    private var FBInvitableFriends = [FacebookInvitableFriend]()

    private var searchKey: String = ""

    private lazy var user: User = {
        return NetworkClient.sharedClient.user
    }()

    @IBOutlet private weak var tableView: UITableView!

    //MARK:- Init
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Friend List"
        self.tableView.registerNib(UINib(nibName: "FriendsChallengeCellTableViewCell", bundle: nil), forCellReuseIdentifier: kTHFriendsChallengeCellTableViewCellIdentifier)
        self.tableView.registerNib(UINib(nibName: "StaffChallengeCellTableViewCell", bundle: nil), forCellReuseIdentifier: kTHStaffChallengeCellTableViewCellIdentifier)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 53
        self.tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, self.tableView.width, 0.01))
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.showNavigationBar()
        self.loadStaff {
            [unowned self] in
            self.loadFriends()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func loadStaff(completionHandler: () -> ()) {
        var hud = JGProgressHUD.progressHUDWithDefaultStyle()
        hud.showInWindow()

        self.THStaffList.removeAll(keepCapacity: true)

        self.tableView.reloadData()
        let object = EGOCache.globalCache().objectForKey(kTHStaffUserCacheStoreKey)

        if !THCache.objectExistForCacheKey(kTHStaffUserCacheStoreKey) {
            debugPrintln("Nothing cached.")
            hud.textLabel.text = "Just a sec.."
            NetworkClient.sharedClient.fetchStaffList({ progress in }, errorHandler: { error in }) {
                [unowned self] in
                hud.dismissAnimated(true)
                THCache.saveStaffListToCache($0)
                self.THStaffList = $0.filter {
                    $0.userId != self.user.userId
                }
                self.tableView.reloadData()
                completionHandler()
            }
            return
        }

        var cachedStaff = THCache.getStaffListFromCache().filter {
            [unowned self] in $0.userId != self.user.userId
        }
        self.THStaffList = cachedStaff
        self.tableView.reloadData()
        completionHandler()

        hud.dismissAnimated(true)
    }

    private func loadInvitableFriends() {
        self.FBInvitableFriends.removeAll(keepCapacity: true)
        FacebookService.sharedService.getInvitableFriends {
            [unowned self] ivFriends in
            self.FBInvitableFriends = ivFriends
            self.tableView.reloadData()

        }
    }

    private func loadFriends() {
        var hud = JGProgressHUD.progressHUDWithDefaultStyle()
        hud.showInWindow()

        self.FBFriendList.removeAll(keepCapacity: true)
        self.THFriendList.removeAll(keepCapacity: true)

        self.tableView.reloadData()

        let loadCompleteHandler: ((fbFriends:[UserFriend], thFriends:[UserFriend]) -> ()) = {
            [unowned self] in
            self.FBFriendList = $0
            self.FBInvitableFriends = self.FBFriendList.map{
                friend in
                var friendDict:[String: AnyObject] = ["id": friend.fbId, "name": friend.name, "picture": ["data": ["url": friend.fbPicUrl]]]
                return FacebookInvitableFriend.decode(JSONValue.parse(friendDict))!
            }
            self.THFriendList = $1
            self.tableView.reloadData()
        }

        if !THCache.objectExistForCacheKey(kTHUserFriendsCacheStoreKey) {
            debugPrintln("Nothing cached.")
            hud.textLabel.text = "Retrieving friends..."
            NetworkClient.sharedClient.fetchFriendListForUser(self.user.userId, errorHandler: { error in debugPrintln(error) }) {
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
        case 1:
            return FBInvitableFriends.count
        case 2:
            return THFriendList.count
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
        case 1:
            var cell = tableView.dequeueReusableCellWithIdentifier(kTHFriendsChallengeCellTableViewCellIdentifier, forIndexPath: indexPath) as FriendsChallengeCellTableViewCell
            let friendUser = FBInvitableFriends[indexPath.row]
            cell.bindInvitableFriend(friendUser, index: indexPath.row)
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
        case 1:
            if FBFriendList.count == 0 {
                return nil
            }
            return self.createFacebookFriendsTableSectionHeaderView()

        case 2:
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
            return THStaffList.isEmpty ? 0 : 25;
        case 1:
            return FBFriendList.isEmpty ? 0 : 25;
        case 2:
            return THFriendList.isEmpty ? 0 : 25;
        default:
            return 0
        }

    }

    //MARK:- FriendsChallengeCellTableViewCellDelegate
    func friendUserCell(cell: FriendsChallengeCellTableViewCell, didTapChallengeUser userID: Int) {
        var hud = JGProgressHUD.progressHUDWithDefaultStyle()
        hud.showInWindow()

        hud.textLabel.text = "Creating challenge..."
        hud.detailTextLabel.text = "Creating game with user.."
        NetworkClient.sharedClient.createChallenge(opponentId: userID, errorHandler: { error in debugPrintln(error) }) {
            [unowned self] in
            hud.dismissAnimated(true)
            let vc = UIStoryboard.quizStoryboard().instantiateViewControllerWithIdentifier("GameLoadingSceneViewController") as GameLoadingSceneViewController
            vc.bindGame($0)
            self.navigationController?.pushViewController(vc, animated: true)

        }
    }

    func friendUserCell(cell: FriendsChallengeCellTableViewCell, didTapInviteUser inviteUser: FacebookInvitableFriend) {
        //TODO: invite user via fb
        FacebookService.sharedService.presentInviteFriendsDialog("I challenged you on TradeHero PopQuiz!", friendsToInvite: [inviteUser])
    }

    func staffChallengeCellTableViewCell(cell: StaffChallengeCellTableViewCell, didTapChallengeWithStaffUser userId: Int) {
        var hud = JGProgressHUD.progressHUDWithDefaultStyle()
        hud.showInWindow()

        hud.textLabel.text = "Creating challenge..."
        hud.detailTextLabel.text = "Creating game with user.."
        NetworkClient.sharedClient.createChallenge(opponentId: userId, errorHandler: { error in debugPrintln(error) }) {
            [unowned self] in
            hud.dismissAnimated(true)
            let vc = UIStoryboard.quizStoryboard().instantiateViewControllerWithIdentifier("GameLoadingSceneViewController") as GameLoadingSceneViewController
            vc.bindGame($0)
            self.navigationController?.pushViewController(vc, animated: true)

        }

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
