//
//  FriendsViewController.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/13/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class FriendsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {

    var friendsList: [THUserFriend] = []
    
    @IBOutlet weak var friendsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController.navigationBarHidden = false
        self.navigationItem.title = "FRIENDS"
        self.friendsTableView.delegate = self
        self.friendsTableView.dataSource = self
        self.friendsTableView.registerNib(UINib(nibName: "FriendsChallengeCellTableViewCell", bundle: nil), forCellReuseIdentifier: "Friend_Cell")
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
        var cell: FriendsChallengeCellTableViewCell! = tableView.dequeueReusableCellWithIdentifier("Friend_Cell", forIndexPath: indexPath) as FriendsChallengeCellTableViewCell
        let friendUser = friendsList[indexPath.row]
        cell.friendNameLabel.text = friendUser.name ?? "Unknown user"
        NetworkClient.fetchImageFromURLString(friendUser.facebookPictureURL, progressHandler: nil, completionHandler: {
            image,error in
            cell.friendAvatarView.image = image
            
        })
        cell.layoutIfNeeded()
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
    
}
