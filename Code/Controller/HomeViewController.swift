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
    private var openChallenges: [Game] = []
    private var opponentPendingChallenges: [Game] = []
    
    private var user: THUser = NetworkClient.sharedClient.authenticatedUser

    private var noOpenChallenge:Bool {
        return self.openChallenges.count == 0
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
        self.setNavigationTintColor(UIColor(hex: 0x303030), buttonColor: UIColor(hex: 0xffffff))
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName : UIFont(name: "AvenirNext-Medium", size: 18), NSForegroundColorAttributeName : UIColor.whiteColor(), NSBackgroundColorAttributeName : UIColor.whiteColor()]
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
        weak var weakSelf = self
        NetworkClient.sharedClient.createQuickGame {
            var strongSelf = weakSelf!
            if let g = $0 {
                hud.textLabel.text = "Creating game with user.."
                
                let vc = UIStoryboard.quizStoryboard().instantiateViewControllerWithIdentifier("GameLoadingSceneViewController") as GameLoadingSceneViewController
                vc.bindGame($0)
                strongSelf.navigationController?.pushViewController(vc, animated: true)
                hud.dismissAnimated(true)
            }
        }
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
        
        weak var wself = self
        let completionHandler: () -> () = {
            numberLoaded++
            var sself = wself!
            
            if numberLoaded == 2 {
                hud?.dismissAnimated(true)
                sself.tableView.reloadData()
                sself.tableView.forceUpdateTable()
            }
            if loadCompleteHandler != nil {
                loadCompleteHandler()
            }
        }
        
        NetworkClient.sharedClient.fetchOpenChallenges {
            var sself = wself!
            sself.openChallenges = $0
           
            sself.openChallenges.sort {
                $0.createdAt.timeIntervalSinceReferenceDate > $1.createdAt.timeIntervalSinceReferenceDate
            }
            completionHandler()
        }
        
        NetworkClient.sharedClient.fetchOpponentPendingChallenges {
            var sself = wself!
            sself.opponentPendingChallenges = $0
            sself.opponentPendingChallenges.sort {
                $0.createdAt.timeIntervalSinceReferenceDate > $1.createdAt.timeIntervalSinceReferenceDate
            }
            completionHandler()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(kTHHomeTurnChallengesTableViewCellIdentifier, forIndexPath:indexPath) as HomeTurnChallengesTableViewCell
        
        switch indexPath.section {
        case 0:
            cell.bindChalllenge(openChallenges[indexPath.row], status:.Accept)
        case 1:
            cell.bindChalllenge(opponentPendingChallenges[indexPath.row], status:.Nudge)
        default:
            break
        }
        
        cell.layoutIfNeeded()
        cell.delegate = self
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return openChallenges.count
        case 1:
            return opponentPendingChallenges.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView! {
        switch section {
        case 0:
            if noOpenChallenge {
                return createHeaderViewForEmptyTurn()
            }
            return createHeaderView("Your turn", numberOfGames: openChallenges.count)
        case 1:
            return createHeaderView("Their turn", numberOfGames: opponentPendingChallenges.count)
        default:
            return nil
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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
    
    
    func homeTurnChallengesCell(cell: HomeTurnChallengesTableViewCell, didTapAcceptChallenge game: Game) {
        switch cell.status {
        case .Accept, .Play:
            var hud = JGProgressHUD.progressHUDWithCustomisedStyleInView(self.view)
            let name = cell.player.displayName == "" || cell.player.displayName == nil ? "opponent" : cell.player.displayName
            hud.textLabel.text = "Accepting \(name)'s challenge"
            hud.detailTextLabel.text = "Initiating game"
            weak var weakSelf = self
            NetworkClient.sharedClient.fetchGameByGameId(game.gameID) {
                var strongSelf = weakSelf!
                var i = 0
                for game in strongSelf.openChallenges {
                    if $0.gameID == game.gameID  {
                        strongSelf.openChallenges.removeAtIndex(i)
                        strongSelf.tableView.reloadData()
                        break
                    }
                    i++
                }
                
                if let g = $0 {
                    let vc = UIStoryboard.quizStoryboard().instantiateViewControllerWithIdentifier("GameLoadingSceneViewController") as GameLoadingSceneViewController
                    vc.bindGame($0)
                    strongSelf.navigationController?.pushViewController(vc, animated: true)
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
        
        var rightLabelView = UILabel(frame: CGRectMake(178, 4, 100, 21))
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
        
        var rightLabelView = UILabel(frame: CGRectMake(178, 4, 100, 21))
        rightLabelView.text = numberOfGames == 1 ? "1 game" : "\(numberOfGames) games"
        rightLabelView.textAlignment = .Right
        rightLabelView.font = UIFont(name: "AvenirNext-Medium", size: 15)
        rightLabelView.textColor = UIColor.whiteColor()
        headerView.addSubview(rightLabelView)
        return headerView
    }
    
    func refresh(sender: UIRefreshControl){
        self.loadChallenges {
            self.refreshControl.endRefreshing()
        }
    }
    
}
