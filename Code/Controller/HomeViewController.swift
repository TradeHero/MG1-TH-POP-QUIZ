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
    
    private var refreshControl: UIRefreshControl!
    private var openChallenges = [Game]()
    private var opponentPendingChallenges = [Game]()
    private var unfinishedChallenges = [Game]()
    private var user: THUser = NetworkClient.sharedClient.user

    private var noOpenChallenges:Bool {
        return self.openChallenges.count == 0
    }
    
    private var noUnfinishedChallenges:Bool {
        return self.unfinishedChallenges.count == 0
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadChallenges()
        refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        self.tableView.addSubview(refreshControl)
        self.tableView.registerNib(UINib(nibName: "HomeTurnChallengesTableViewCell", bundle: nil), forCellReuseIdentifier: kTHHomeTurnChallengesTableViewCellIdentifier)
        setupSubviews()
        self.navigationController?.setNavigationTintColor(barColor: UIColor(hex: 0x303030), buttonColor: UIColor(hex: 0xffffff))
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName : UIFont(name: "AvenirNext-Medium", size: 18), NSForegroundColorAttributeName : UIColor.whiteColor(), NSBackgroundColorAttributeName : UIColor.whiteColor()]
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 53
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        self.tableView.forceUpdateTable()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.showNavigationBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Actions
    
    @IBAction func quickGameAction(sender: UIButton) {
        var hud = JGProgressHUD.progressHUDWithCustomisedStyleInView(self.view)
        hud.textLabel.text = "Creating quick game..."
        NetworkClient.sharedClient.createQuickGame {
            [unowned self] in
            if let g = $0 {
                hud.textLabel.text = "Creating game with user.."
                
                let vc = UIStoryboard.quizStoryboard().instantiateViewControllerWithIdentifier("GameLoadingSceneViewController") as GameLoadingSceneViewController
                vc.bindGame($0)
                self.navigationController?.pushViewController(vc, animated: true)
                hud.dismissAnimated(true)
            }
        }
    }
    
    //MARK:- Private functions
    private func setupSubviews() {
        NetworkClient.fetchImageFromURLString(user.pictureURL, progressHandler: nil)  {[unowned self]
            (image: UIImage!, error:NSError!) in
            if image != nil {
                self.avatarView.image = image
            }
        }
        self.fullNameView.text = user.displayName
    }
    
    private func loadChallenges(loadCompleteHandler:(()->())! = nil){
        var hud: JGProgressHUD?
        if loadCompleteHandler == nil {
            hud = JGProgressHUD.progressHUDWithCustomisedStyleInView(self.view)

            self.openChallenges.removeAll(keepCapacity: true)
            self.opponentPendingChallenges.removeAll(keepCapacity: true)
            self.tableView.reloadData()
            self.tableView.forceUpdateTable()
        }
        
        var numberLoaded = 0
        
        hud?.textLabel.text = "Loading challenges.."
        
        let completionHandler: () -> () = {[unowned self] in
            numberLoaded++
            
            if numberLoaded == 3 {
                hud?.dismissAnimated(true)
                self.tableView.reloadData()
                self.tableView.forceUpdateTable()
            }
            if loadCompleteHandler != nil {
                loadCompleteHandler()
            }
        }
        
        NetworkClient.sharedClient.fetchOpenChallenges {
            [unowned self] in
            self.openChallenges = $0
           
            self.openChallenges.sort {
                $0.createdAt.timeIntervalSinceReferenceDate > $1.createdAt.timeIntervalSinceReferenceDate
            }
            completionHandler()
        }
        
        NetworkClient.sharedClient.fetchOpponentPendingChallenges {
            [unowned self] in
            self.opponentPendingChallenges = $0
            self.opponentPendingChallenges.sort {
                $0.createdAt.timeIntervalSinceReferenceDate > $1.createdAt.timeIntervalSinceReferenceDate
            }
            completionHandler()
        }
        
        NetworkClient.sharedClient.fetchIncompleteChallenges {
            [unowned self] in
            self.unfinishedChallenges = $0
            self.unfinishedChallenges.sort {
                $0.createdAt.timeIntervalSinceReferenceDate > $1.createdAt.timeIntervalSinceReferenceDate
            }
            completionHandler()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(kTHHomeTurnChallengesTableViewCellIdentifier, forIndexPath:indexPath) as HomeTurnChallengesTableViewCell
        
        switch indexPath.section {
        case 0:
            cell.bindChalllenge(unfinishedChallenges[indexPath.row], status:.Play)
        case 1:
            cell.bindChalllenge(openChallenges[indexPath.row], status:.Accept)
        case 2:
            cell.bindChalllenge(opponentPendingChallenges[indexPath.row], status:.Nudge)
        default:
            break
        }
        
        cell.layoutIfNeeded()
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        cell.delegate = self
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 53
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return unfinishedChallenges.count
        case 1:
            return openChallenges.count
        case 2:
            return opponentPendingChallenges.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView! {
        switch section {
        case 0:
            return noUnfinishedChallenges ? nil : createHeaderView("Unfinished challenge", numberOfGames: unfinishedChallenges.count)
        case 1:
            if noOpenChallenges {
                return createHeaderViewForEmptyTurn()
            }
            return createHeaderView("Your turn", numberOfGames: openChallenges.count)
        case 2:
            return createHeaderView("Their turn", numberOfGames: opponentPendingChallenges.count)
        default:
            return nil
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            if noUnfinishedChallenges {
                return 0
            }
            return 25

        case 1:
            if noOpenChallenges {
                return 119
            }
            return 25
        case 2:
            return 25
        default:
            return 0
        }
    }
    
    
    func homeTurnChallengesCell(cell: HomeTurnChallengesTableViewCell, didTapAcceptChallenge game: Game) {
        switch cell.status {
        case .Accept, .Play:
            var hud = JGProgressHUD.progressHUDWithCustomisedStyleInView(self.view)
            let name = cell.player.displayName == "" || cell.player.displayName == nil ? "opponent" : cell.player.displayName
            if self.user.displayName == name {
                hud.textLabel.text = "Accepting \(name)'s challenge"
            } else {
                hud.textLabel.text = "Complete previous challenge"
            }
            
            hud.detailTextLabel.text = "Initiating game"
            
            NetworkClient.sharedClient.fetchGame(game.gameID, force: true) {
                [unowned self] in
                var i = 0
                for game in self.openChallenges {
                    if $0.gameID == game.gameID  {
                        self.openChallenges.removeAtIndex(i)
                        self.tableView.reloadData()
                        break
                    }
                    i++
                }
                
                if let g = $0 {
                    let vc = UIStoryboard.quizStoryboard().instantiateViewControllerWithIdentifier("GameLoadingSceneViewController") as GameLoadingSceneViewController
                    vc.bindGame($0)
                    self.navigationController?.pushViewController(vc, animated: true)
                    hud.dismissAnimated(true)
                }
            }
        case .Nudge:
            //TODO send notification
            cell.configureAsInvitedMode()
        default:
            break
        }
    }
    
    //MARK:- UI methods
    private func createHeaderViewForEmptyTurn() -> UITableViewHeaderFooterView {
        var headerView = UITableViewHeaderFooterView(frame: CGRectMake(0, 0, 286, 119))
        var leftLabelView = UILabel.newAutoLayoutView()
        leftLabelView.frame = CGRectMake(4, 4, 72, 21)
        leftLabelView.text = "Your Turn"
        leftLabelView.font = UIFont(name: "AvenirNext-Medium", size: 15)
        leftLabelView.textColor = UIColor.whiteColor()
        headerView.contentView.addSubview(leftLabelView)
        
        var rightLabelView = UILabel.newAutoLayoutView()
        rightLabelView.frame = CGRectMake(178, 4, 100, 21)
        rightLabelView.text = "0 games"
        rightLabelView.textAlignment = .Right
        rightLabelView.font = UIFont(name: "AvenirNext-Medium", size: 15)
        rightLabelView.textColor = UIColor.whiteColor()
        headerView.contentView.addSubview(rightLabelView)
        
        var logoView = UIImageView.newAutoLayoutView()
        logoView.frame = CGRectMake(119, 23, 51, 51)
        logoView.image = UIImage(named: "NoChallengeEmoticon")
        headerView.contentView.addSubview(logoView)

        var textLabel = UILabel.newAutoLayoutView()
        textLabel.frame = CGRectMake(40, 81, 208, 38)
        textLabel.text = "No pending game. \r Why don’t you start a challenge?"
        textLabel.numberOfLines = 2
        textLabel.textAlignment = .Center
        textLabel.font = UIFont(name: "AvenirNext-Regular", size: 13)
        textLabel.textColor = UIColor.whiteColor()
        textLabel.lineBreakMode = .ByWordWrapping
        headerView.contentView.addSubview(textLabel)
        
        UIView.autoSetPriority(750) {
            leftLabelView.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
            rightLabelView.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
            logoView.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
            textLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
        }
        
        leftLabelView.autoPinEdgeToSuperviewEdge(.Top, withInset: 4)
        leftLabelView.autoPinEdgeToSuperviewEdge(.Leading, withInset: 4)
        
        rightLabelView.autoPinEdgeToSuperviewEdge(.Top, withInset: 4)
        rightLabelView.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 8)
        
        logoView.autoPinEdgeToSuperviewEdge(.Top, withInset: 23)
        logoView.autoConstrainAttribute(NSLayoutAttribute.CenterX.toRaw(), toAttribute: NSLayoutAttribute.CenterX.toRaw(), ofView: logoView.superview, withMultiplier: 1)
        logoView.autoConstrainAttribute(NSLayoutAttribute.Width.toRaw(), toAttribute: NSLayoutAttribute.Height.toRaw(), ofView: logoView, withMultiplier: 1.0)
        logoView.autoSetDimension(.Height, toSize: 51)

        textLabel.autoConstrainAttribute(NSLayoutAttribute.CenterX.toRaw(), toAttribute: NSLayoutAttribute.CenterX.toRaw(), ofView: textLabel.superview, withMultiplier: 1)
        textLabel.autoSetDimensionsToSize(CGSizeMake(208, 38))
        textLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: logoView, withOffset: 7)
        
        return headerView
    }
    
    private func createHeaderView(title:String, numberOfGames:Int) -> UITableViewHeaderFooterView {
        var headerView = UITableViewHeaderFooterView(frame: CGRectMake(0, 0, 286, 25))
        var leftLabelView = UILabel.newAutoLayoutView()
        leftLabelView.frame = CGRectMake(4, 4, 72, 21)
        leftLabelView.text = title
        leftLabelView.font = UIFont(name: "AvenirNext-Medium", size: 15)
        leftLabelView.textColor = UIColor.whiteColor()
        headerView.contentView.addSubview(leftLabelView)
        
        var rightLabelView = UILabel.newAutoLayoutView()
        rightLabelView.frame = CGRectMake(178, 4, 100, 21)
        rightLabelView.text = numberOfGames == 1 ? "1 game" : "\(numberOfGames) games"
        rightLabelView.textAlignment = .Right
        rightLabelView.font = UIFont(name: "AvenirNext-Medium", size: 15)
        rightLabelView.textColor = UIColor.whiteColor()
        headerView.contentView.addSubview(rightLabelView)
        
        UIView.autoSetPriority(1000) {
            leftLabelView.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
            rightLabelView.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
        }
        
        leftLabelView.autoPinEdgeToSuperviewEdge(.Top, withInset: 4)
        leftLabelView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 0)
        leftLabelView.autoPinEdgeToSuperviewEdge(.Leading, withInset: 4)
        
        rightLabelView.autoPinEdgeToSuperviewEdge(.Top, withInset: 4)
        rightLabelView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 0)
        rightLabelView.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 8)

        return headerView
    }
    
    func refresh(sender: UIRefreshControl){
        self.loadChallenges {
            self.refreshControl.endRefreshing()
        }
    }
    
}
