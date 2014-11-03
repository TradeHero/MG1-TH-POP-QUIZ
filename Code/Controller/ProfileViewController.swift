//
//  ProfileViewController.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 9/12/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController,UITableViewDelegate, UITableViewDataSource
{
    
    @IBOutlet private weak var tableView: UITableView!

    @IBOutlet private weak var displayNameLabel: UILabel!

    @IBOutlet private weak var profilePicView: AvatarRoundedView!
    
    private var defaultText:String!
    
    private var closedChallenges: [Game] = []
    
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
    
    @IBAction func updateAction(sender: AnyObject) {
        var hud = JGProgressHUD.progressHUDWithCustomisedStyleInView(self.view, style: .Dark)
        hud.textLabel.text = "Updating profile..."
        //TODO: update profile
        hud.dismissAfterDelay(2.0)
    }
    
    
    func loadClosedChallenges() {
        var hud = JGProgressHUD.progressHUDWithCustomisedStyleInView(self.view)
        hud.textLabel.text = "Refreshing timeline.."
        NetworkClient.sharedClient.fetchClosedChallenges({error in debugPrintln(error)}) {
            [unowned self] in
            var challenges = $0
            challenges.sort { $1.createdAt.timeIntervalSinceReferenceDate > $0.createdAt.timeIntervalSinceReferenceDate }
            
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
            self.profilePicView.image  = image
        }
        
        self.displayNameLabel.text = user.displayName
        
        //Empty timeline view
        self.view.addSubview(emptyTimelineView)
        
        //Auto-layout constraints
        self.emptyTimelineView.setNeedsUpdateConstraints()
        self.emptyTimelineView.updateConstraintsIfNeeded()
        UIView.autoSetPriority(750) { }
        self.emptyTimelineView.autoConstrainAttribute(.Vertical, toAttribute: .Vertical, ofView: self.emptyTimelineView.superview, withMultiplier: 1)
        self.emptyTimelineView.autoConstrainAttribute(.Horizontal, toAttribute: .Horizontal, ofView: self.emptyTimelineView.superview, withMultiplier: 1)
        self.emptyTimelineView.autoSetDimensionsToSize(CGSizeMake(258, 284))
    }
    
    // MARK:- UITableView delegate methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kTHChallengesTimelineTableViewCellIdentifier) as ChallengesTimelineTableViewCell
        cell.bindGame(closedChallenges[indexPath.row])
        if indexPath.row == closedChallenges.count - 1 {
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
        return closedChallenges.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = NSBundle.mainBundle().loadNibNamed("ChallengesSectionHeader", owner: nil, options: nil)[0] as? UIView
        return view
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return UIView(frame: CGRectZero)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return closedChallenges.count > 0 ? 1 : 0
    }
}
