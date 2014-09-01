//
//  HomeViewController.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/5/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HomeTurnChallengesTableViewCellDelegate {

    @IBOutlet private weak var avatarView: AvatarRoundedView!
    @IBOutlet private weak var fullNameView: UILabel!
    @IBOutlet private weak var rankView: UILabel!
    
    private var openChallenges: [Game] = []
    private var takenChallenges: [Game] = []
    
    private lazy var user: THUser = {
        return NetworkClient.sharedClient.authenticatedUser
    }()
    
    private lazy var noOpenChallenge:Bool = {
        return self.openChallenges.count == 0
    }()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadChallenges()
        self.tableView.registerNib(UINib(nibName: "HomeTurnChallengesTableViewCell", bundle: nil), forCellReuseIdentifier: kTHHomeTurnChallengesTableViewCellIdentifier)
        setupSubviews()
        self.setNavigationTintColor(UIColor(hex: 0x303030), buttonColor: UIColor(hex: 0xffffff))
        self.navigationItem.title = "Home"
        self.navigationController.navigationBar.titleTextAttributes = [ NSFontAttributeName : UIFont(name: "AvenirNext-Medium", size: 18), NSForegroundColorAttributeName : UIColor.whiteColor(), NSBackgroundColorAttributeName : UIColor.whiteColor()]
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController.showNavigationBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "FriendsViewPushSegue" {
            let vc = segue.destinationViewController as FriendsViewController
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
    
    private func loadChallenges(){
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.removeFromSuperViewOnHide = true
        hud.minShowTime = 0
        hud.labelFont = UIFont(name: "AvenirNext-Medium", size: 15)
        
        var numberLoaded = 0
        self.openChallenges.removeAll(keepCapacity: true)
        self.takenChallenges.removeAll(keepCapacity: true)
        self.tableView.reloadData()
        hud.labelText = "Loading challenges.."
        let completionHandler: () -> Void = {
            numberLoaded++
            if numberLoaded == 2 {
                hud.hide(true)
                self.tableView.reloadData()
            }
        }
        
        weak var wself = self
        NetworkClient.sharedClient.fetchOpenChallenges() {
            var sself = wself!
            sself.openChallenges = $0
            println("Fetched \($0.count) open challenges.")
            completionHandler()
        }
        
        NetworkClient.sharedClient.fetchTakenChallenges() {
            var sself = wself!
            sself.takenChallenges = $0
            println("Fetched \($0.count) taken challenges")
            completionHandler()
        }
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell = tableView.dequeueReusableCellWithIdentifier(kTHHomeTurnChallengesTableViewCellIdentifier, forIndexPath:indexPath) as HomeTurnChallengesTableViewCell
        
        switch indexPath.section {
        case 0:
            cell.bindChalllenge(openChallenges[indexPath.row])
        case 1:
            cell.bindChalllenge(takenChallenges[indexPath.row])
        default:
            return nil
        }
        
        cell.layoutIfNeeded()
        cell.delegate = self
        return cell
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 48.0
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return openChallenges.count
        case 1:
            return takenChallenges.count
        default:
            return 0
        }
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
    
    
    func homeTurnChallengesCell(cell: HomeTurnChallengesTableViewCell, didTapAcceptChallenge challengeId: Int) {
        
    }
    
    //MARK:- UI methods
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

}
