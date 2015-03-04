//
//  HomeViewController.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 8/5/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import WYPopoverController
import JGProgressHUD

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HomeTurnChallengesTableViewCellDelegate, FriendsChallengeCellTableViewCellDelegate, WYPopoverControllerDelegate {

    @IBOutlet private weak var avatarView: AvatarRoundedView!
    @IBOutlet private weak var fullNameView: UILabel!
    @IBOutlet weak var tickImageView: UIImageView!

    @IBOutlet weak var muteButton: UIButton!

    private var openChallenges = [Game]()
    private var opponentPendingChallenges = [Game]()
    private var unfinishedChallenges = [Game]()
    private var user: THUser = NetworkClient.sharedClient.user

    @IBOutlet weak var internalUserView: UIImageView!
    private var facebookFriendsChallenge = [THUserFriend]()

    private var noOpenChallenges: Bool {
        return self.openChallenges.count == 0
    }

    var popoverController: WYPopoverController!

    private var noUnfinishedChallenges: Bool {
        return self.unfinishedChallenges.count == 0
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: "HomeTurnChallengesTableViewCell", bundle: nil), forCellReuseIdentifier: kTHHomeTurnChallengesTableViewCellIdentifier)
        self.tableView.registerNib(UINib(nibName: "FriendsChallengeCellTableViewCell", bundle: nil), forCellReuseIdentifier: kTHFriendsChallengeCellTableViewCellIdentifier)
        setupSubviews()
        self.navigationController?.setNavigationTintColor(barColor: UIColor(hex: 0x303030), buttonColor: UIColor(hex: 0xffffff))
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 18)!, NSForegroundColorAttributeName: UIColor.whiteColor(), NSBackgroundColorAttributeName: UIColor.whiteColor()]
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 53
        self.tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, self.tableView.width, 0.01))
        self.internalUserView.hidden = !isInternalUser(user)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loadChallenges()
        self.tableView.reloadData()
        self.tableView.forceUpdateTable()
        self.muteButton.selected = true
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.showNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func muteAction(sender: UIButton) {
//        if self.muteButton.selected {
//            self.muteButton.selected = false
//            kTHBackgroundMusicValue = 0.5
//        } else {
//            self.muteButton.selected = true
//            kTHBackgroundMusicValue = 0
//        }

        let content = UIStoryboard.inAppNotificationStoryboard().instantiateViewControllerWithIdentifier("MusicChooserTableViewController") as? UIViewController

        content?.preferredContentSize = CGSizeMake(320, 400)
        popoverController = WYPopoverController(contentViewController: content)

        popoverController.delegate = self
        var theme = WYPopoverTheme.themeForIOS7()
        theme.tintColor = UIColor(hex: 0xDB0231)
        theme.fillTopColor = UIColor(hex: 0xDB0231)
        theme.fillBottomColor = UIColor(hex: 0xDB0231)
        WYPopoverController.setDefaultTheme(theme)
        popoverController.wantsDefaultContentAppearance = false

//        appearance.fillBottomColor = UIColor(hex: 0xDB0231)
        popoverController.presentPopoverFromRect(sender.bounds, inView: sender, permittedArrowDirections: .Any, animated: true)

    }
    //MARK:- Actions

    @IBAction func quickGameAction(sender: UIButton) {
        var hud = JGProgressHUD.progressHUDWithDefaultStyle()
        hud.showInWindow()
        hud.textLabel.text = "Creating quick game..."
        NetworkClient.sharedClient.createQuickGame({ error in debugPrintln(error) }) {
            [unowned self] in
            hud.textLabel.text = "Creating game with user.."
            let vc = UIStoryboard.quizStoryboard().instantiateViewControllerWithIdentifier("GameLoadingSceneViewController") as GameLoadingSceneViewController
            vc.bindGame($0)
            self.navigationController?.pushViewController(vc, animated: true)
            hud.dismissAnimated(true)
        }
    }

    @IBAction func uncheckFBShareAction(sender: UIButton) {
        func showAlertViewConfirmation() {
            let alertView = UIAlertController(title: "Facebook Sharing", message: "Are you sure you want to do this?", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Yes, challenge my friends!", style: .Cancel, handler: nil)

            let okAction = UIAlertAction(title: "Later", style: .Default) {
                [unowned self] action in
                kFaceBookShare = false
                sender.selected = false
            }

            alertView.addAction(cancelAction)
            alertView.addAction(okAction)
            self.presentViewController(alertView, animated: true, completion: nil)
        }

        if kFaceBookShare {
            showAlertViewConfirmation()
        } else {
            kFaceBookShare = true
            sender.selected = true
        }

    }

    @IBOutlet weak var uncheckAction: UIImageView!
    //MARK:- Private functions
    private func setupSubviews() {
        NetworkClient.fetchImageFromURLString(user.pictureURL, progressHandler: nil) {
            [unowned self] (image: UIImage!, error: NSError!) in
            if image != nil {
                self.avatarView.image = image
            }
        }
        self.fullNameView.text = user.displayName
    }

    private func loadChallenges(loadCompleteHandler: (() -> ())! = nil) {
        var hud = JGProgressHUD.customisedProgressHUDWithStyle(.Dark, textLabelFont: UIFont(name: "AngryBirds-Regular", size: 14)!, detailLabelFont: UIFont(name: "HelveticaNeue", size: 9)!, interactionType: .BlockTouchesOnHUDView, position: .BottomCenter, labelText: loadCompleteHandler == nil ? "Loading challenges.." : "Syncing..")
        hud.showInWindow()
        if loadCompleteHandler == nil {
            self.openChallenges.removeAll(keepCapacity: true)
            self.opponentPendingChallenges.removeAll(keepCapacity: true)
            self.tableView.reloadData()
            self.tableView.forceUpdateTable()
        }
//        hud.detailTextLabel.text = "0% complete"
        var numberLoaded = 0

        let completionHandler: () -> () = {
            [unowned self] in
            numberLoaded++

            let progress = (Double(numberLoaded) * 100 / 2).format(".1")
            hud.setProgress(Float(numberLoaded) / 2, animated: false)
//            hud.detailTextLabel.text = "\(progress)% complete"

            if numberLoaded == 2 {
//                hud.indicatorView = JGProgressHUDSuccessIndicatorView()
//                hud.layoutChangeAnimationDuration = 0.3
//                hud.textLabel.text = nil
//                hud.detailTextLabel.text = nil
                hud?.dismissAfterDelay(1, animated: true)
                self.tableView.reloadData()
            }

            if loadCompleteHandler != nil {
                loadCompleteHandler()
            }
        }

        NetworkClient.sharedClient.fetchAllChallenges({
            error in
            debugPrintln(error)
        }) {
            [unowned self] in

            self.unfinishedChallenges = $0.unfinishedChallenges
            self.unfinishedChallenges.sort {
                $0.createdAt.timeIntervalSinceReferenceDate > $1.createdAt.timeIntervalSinceReferenceDate
            }
            self.openChallenges = $0.openChallenges
            self.openChallenges.sort {
                $0.createdAt.timeIntervalSinceReferenceDate > $1.createdAt.timeIntervalSinceReferenceDate
            }
            self.opponentPendingChallenges = $0.opponentPendingChallenges
            self.opponentPendingChallenges.sort {
                $0.createdAt.timeIntervalSinceReferenceDate > $1.createdAt.timeIntervalSinceReferenceDate
            }

            completionHandler()
        }

        NetworkClient.sharedClient.getRandomFBFriendsForUser(numberOfUsers: 3, forUser: user.userId, errorHandler: { error in debugPrintln(error) }) {
            [unowned self] in
            self.facebookFriendsChallenge = $0
            completionHandler()
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            var cell = tableView.dequeueReusableCellWithIdentifier(kTHHomeTurnChallengesTableViewCellIdentifier, forIndexPath: indexPath) as HomeTurnChallengesTableViewCell
            cell.bindChalllenge(unfinishedChallenges[indexPath.row], status: .Play)
            cell.layoutIfNeeded()
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            cell.delegate = self
            return cell
        case 1:
            var cell = tableView.dequeueReusableCellWithIdentifier(kTHHomeTurnChallengesTableViewCellIdentifier, forIndexPath: indexPath) as HomeTurnChallengesTableViewCell
            cell.bindChalllenge(openChallenges[indexPath.row], status: .Accept)
            cell.layoutIfNeeded()
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            cell.delegate = self
            return cell
        case 2:
            let row = indexPath.row
            let offset = opponentPendingChallenges.count
            if row < offset {
                var cell = tableView.dequeueReusableCellWithIdentifier(kTHHomeTurnChallengesTableViewCellIdentifier, forIndexPath: indexPath) as HomeTurnChallengesTableViewCell
                cell.bindChalllenge(opponentPendingChallenges[row], status: .Nudge)
                cell.layoutIfNeeded()
                cell.setNeedsUpdateConstraints()
                cell.updateConstraintsIfNeeded()
                cell.delegate = self
                return cell
            } else {
                var cell = tableView.dequeueReusableCellWithIdentifier(kTHFriendsChallengeCellTableViewCellIdentifier, forIndexPath: indexPath) as FriendsChallengeCellTableViewCell
                cell.bindFriendUser(facebookFriendsChallenge[row - offset], index: 0)
                cell.delegate = self
                cell.layoutIfNeeded()
                cell.setNeedsUpdateConstraints()
                cell.updateConstraintsIfNeeded()
                return cell
            }
        default:
            return UITableViewCell()
        }
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
            return opponentPendingChallenges.count + facebookFriendsChallenge.count
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
            var hud = JGProgressHUD.progressHUDWithDefaultStyle()
            hud.showInWindow()
            hud.textLabel.text = "Getting ready.."

            NetworkClient.sharedClient.fetchGame(game.gameID, force: true, errorHandler: { error in debugPrintln(error) }) {
                [unowned self] in
                var i = 0
                for game in self.openChallenges {
                    if $0.gameID == game.gameID {
                        self.openChallenges.removeAtIndex(i)
                        self.tableView.reloadData()
                        break
                    }
                    i++
                }

                let vc = UIStoryboard.quizStoryboard().instantiateViewControllerWithIdentifier("GameLoadingSceneViewController") as GameLoadingSceneViewController
                vc.bindGame($0)
                self.navigationController?.pushViewController(vc, animated: true)
                hud.dismissAnimated(true)
            }
        case .Nudge:
            //TODO send notification
            NetworkClient.sharedClient.nudgeGameUser(game) {
            }
            cell.configureAsNudgedMode()
            cell.game.lastNudgedOpponentAtUTCStr = DataFormatter.shared.dateFormatter.stringFromDate(NSDate())
        default:
            break
        }
    }

    func friendUserCell(cell: FriendsChallengeCellTableViewCell, didTapChallengeUser userID: Int) {
        var hud = JGProgressHUD.progressHUDWithDefaultStyle()
        hud.showInWindow()
        hud.textLabel.text = "Creating challenge..."
        NetworkClient.sharedClient.createChallenge(opponentId: userID, errorHandler: { error in debugPrintln(error) }) {
            [unowned self] in
            hud.dismissAnimated(true)
            let vc = UIStoryboard.quizStoryboard().instantiateViewControllerWithIdentifier("GameLoadingSceneViewController") as GameLoadingSceneViewController
            vc.bindGame($0)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func friendUserCell(cell: FriendsChallengeCellTableViewCell, didTapInviteUser inviteUser: FacebookInvitableFriend) {
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
        logoView.autoConstrainAttribute(.Vertical, toAttribute: .Vertical, ofView: logoView.superview, withMultiplier: 1)
        logoView.autoConstrainAttribute(.Width, toAttribute: .Height, ofView: logoView, withMultiplier: 1.0)
        logoView.autoSetDimension(.Height, toSize: 51)
        textLabel.autoConstrainAttribute(.Vertical, toAttribute: .Vertical, ofView: textLabel.superview, withMultiplier: 1)
        textLabel.autoSetDimensionsToSize(CGSizeMake(208, 38))
        textLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: logoView, withOffset: 7)

        return headerView
    }

    private func createHeaderView(title: String, numberOfGames: Int) -> UITableViewHeaderFooterView {
        var headerView = UITableViewHeaderFooterView.newAutoLayoutView()
        headerView.frame = CGRectMake(0, 0, 286, 25)
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

    @IBAction func refresh(sender: AnyObject) {
        self.loadChallenges {
        }
    }

    func popoverControllerShouldDismissPopover(popoverController: WYPopoverController!) -> Bool {
        return true
    }

}
