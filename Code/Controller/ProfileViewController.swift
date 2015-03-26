//
//  ProfileViewController.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 9/12/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import JGProgressHUD

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet private weak var tableView: UITableView!

    @IBOutlet private weak var displayNameLabel: UILabel!

    @IBOutlet private weak var profilePicView: AvatarRoundedView!

    private var defaultText: String!

    private var closedChallenges: [Game] = []

    private var categorisedClosedChallenges = [String: [Game]]()

    private var closedChallengeCategories = [String]()

    private var user = NetworkClient.sharedClient.user

    private lazy var emptyTimelineView: UIView = {
        var view = NSBundle.mainBundle().loadNibNamed("EmptyTimelineView", owner: nil, options: nil)[0] as UIView
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadClosedChallenges()
        self.tableView.registerNib(UINib(nibName: "ChallengesTimelineTableViewCell", bundle: nil), forCellReuseIdentifier: kTHChallengesTimelineTableViewCellIdentifier)
        tableView.alwaysBounceVertical = false
        self.configureUI()
        
        tableView.hidden = true
        emptyTimelineView.hidden = true
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.showNavigationBar()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }


    func categoriseChallenges(challenges: [Game]) {
        if challenges.count == 0 {
            return
        }

        for game in challenges {
//            let date = NSCalendar.currentCalendar().dateFromComponents(NSCalendar.currentCalendar().components(.DayCalendarUnit | .MonthCalendarUnit | .YearCalendarUnit, fromDate: game.createdAt))!
            var exp = DataFormatter.shared.timeIntervalFormatter.stringForTimeIntervalFromDate(NSDate(), toDate: game.completedAt)
//            println(exp)

            if var games = categorisedClosedChallenges[exp] {
                games.append(game)
                categorisedClosedChallenges.updateValue(games, forKey: exp)
            } else {
                closedChallengeCategories.append(exp)
                categorisedClosedChallenges.updateValue([game], forKey: exp)
            }
        }
    }

    func loadClosedChallenges() {
        var hud = JGProgressHUD.progressHUDWithDefaultStyle()
        hud.showInWindow()
        hud.textLabel.text = "Refreshing timeline.."
        categorisedClosedChallenges.removeAll(keepCapacity: true)

        NetworkClient.sharedClient.fetchClosedChallenges({ error in debugPrintln(error) }) {
            [unowned self] in
            var challenges = $0
            challenges.sort {
                $1.completedAt.timeIntervalSinceReferenceDate < $0.completedAt.timeIntervalSinceReferenceDate
            }
//            for c in challenges {
//                println(c.completedAt)
//            }
            self.categoriseChallenges(challenges)

//            println(self.categorisedClosedChallenges.keys.array)
//            println(self.closedChallengeCategories)

            self.closedChallenges = challenges
            self.tableView.reloadData()
            let shouldNotHideTableViewForEmptyView = challenges.count > 0
            self.tableView.hidden = !shouldNotHideTableViewForEmptyView
            self.emptyTimelineView.hidden = shouldNotHideTableViewForEmptyView

            hud.dismissAnimated(true)

        }
    }

    private func configureUI() {
        NetworkClient.fetchImageFromURLString(user.pictureURL, progressHandler: nil) {
            [unowned self] image, error in
            if error != nil {
                println(error)
            }
            self.profilePicView.image = image
        }

        self.displayNameLabel.text = user.displayName

        //Empty timeline view
        self.view.addSubview(emptyTimelineView)

        //Auto-layout constraints
        self.emptyTimelineView.setNeedsUpdateConstraints()
        self.emptyTimelineView.updateConstraintsIfNeeded()
        UIView.autoSetPriority(750) {
        }
        self.emptyTimelineView.autoConstrainAttribute(.Vertical, toAttribute: .Vertical, ofView: self.emptyTimelineView.superview, withMultiplier: 1)
        self.emptyTimelineView.autoConstrainAttribute(.Horizontal, toAttribute: .Horizontal, ofView: self.emptyTimelineView.superview, withMultiplier: 1)
        self.emptyTimelineView.autoSetDimensionsToSize(CGSizeMake(258, 284))
    }

    // MARK:- UITableView delegate methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kTHChallengesTimelineTableViewCellIdentifier) as ChallengesTimelineTableViewCell
        let games = categorisedClosedChallenges[closedChallengeCategories[indexPath.section]]!

        cell.bindGame(games[indexPath.row])
        if indexPath.row == games.count - 1 && indexPath.section == closedChallengeCategories.count - 1 {
            cell.lowerVerticalBar.hidden = true
        }
        return cell
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40

    }

    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categorisedClosedChallenges[closedChallengeCategories[section]]!.count
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = NSBundle.mainBundle().loadNibNamed("ChallengesSectionHeader", owner: nil, options: nil)[0] as? ChallengesSectionHeader
        view?.dateLabel.text = closedChallengeCategories[section]
        return view
    }

    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        return UIView(frame: CGRectZero)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return closedChallenges.count > 0 ? 1 : 0
        return closedChallengeCategories.count
    }
}
