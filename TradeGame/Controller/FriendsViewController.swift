//
//  FriendsViewController.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/13/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class FriendsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, FriendsChallengeCellTableViewCellDelegate {

    var friendsList: [THUserFriend] = []
    
    @IBOutlet weak var friendsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController.navigationBarHidden = false
        self.navigationItem.title = "Friends"
        self.friendsTableView.delegate = self
        self.friendsTableView.dataSource = self
        self.friendsTableView.registerNib(UINib(nibName: "FriendsChallengeCellTableViewCell", bundle: nil), forCellReuseIdentifier: kTHFriendsChallengeCellTableViewCellIdentifier)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Data source
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return friendsList.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell: FriendsChallengeCellTableViewCell! = tableView.dequeueReusableCellWithIdentifier(kTHFriendsChallengeCellTableViewCellIdentifier, forIndexPath: indexPath) as FriendsChallengeCellTableViewCell
        let friendUser = friendsList[indexPath.row]
        
        cell.bindFriendUser(friendUser)
        cell.layoutIfNeeded()
        cell.delegate = self
        return cell
    }
   required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    //MARK:- Delegate
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 70.0
    }
    
    func friendUserCell(cell: FriendsChallengeCellTableViewCell, didTapChallengeUser userID: Int) {
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Creating challenge..."
        
        weak var weakSelf = self
        NetworkClient.sharedClient.createChallenge(10, opponentId: userID, completionHandler: {
        game in
            var strongSelf = weakSelf!
            if let g = game {
                hud.mode = MBProgressHUDModeText
                hud.detailsLabelText = "Creating game with user.."
                println(game)
                let vc = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier("QuizViewController") as QuizViewController
                hud.mode = MBProgressHUDModeAnnularDeterminate
                
                vc.prepareGame(game, hud:hud) {
                    progress -> () in
                    var strongSelf = weakSelf!
                    hud.detailsLabelText = "Done fetching image."
                    hud.hide(true, afterDelay: 1)
                    strongSelf.presentViewController(vc, animated: true, completion: nil)
                }
            }
            
        })
        
    }
    
}
