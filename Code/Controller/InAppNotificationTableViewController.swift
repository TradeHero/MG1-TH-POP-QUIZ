//
//  InAppNotificationTableViewController.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 7/10/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class InAppNotificationTableViewController: UITableViewController, NotificationTableViewCellDelegate {

    private var notifications = [GameNotification]()

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationItem.title = "Notifications"
        self.navigationController?.setNavigationTintColor(barColor: UIColor(hex: 0xFF4069))
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 18)!, NSForegroundColorAttributeName: UIColor.whiteColor(), NSBackgroundColorAttributeName: UIColor.whiteColor()]

        self.tableView.registerNib(UINib(nibName: "NotificationTableViewCell", bundle: nil), forCellReuseIdentifier: kTHNotificationTableViewCellIdentifier)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 70
        self.navigationController?.navigationBar.translucent = false
        self.loadNotifications()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return notifications.count
    }

    func loadNotifications() {
        self.notifications.removeAll(keepCapacity: true)
        self.tableView.reloadData()
        for i in 0 ..< 15 {
            let notification = GameNotification(type: .New, title: "Lorem ipsum", details: "Dolor sit amet", urlString: "http://i.imgur.com/lYhUHw6.png")
            notification.read = i % 2 == 0 ? true : false
            notification.type = i % 2 == 0 ? .Nudged : .New
            notifications.append(notification)
        }
        self.tableView.reloadData()
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kTHNotificationTableViewCellIdentifier, forIndexPath: indexPath) as NotificationTableViewCell

        cell.bindNotification(notifications[indexPath.row])
        cell.delegate = self

        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }

    func notificationTableViewCell(cell: NotificationTableViewCell, didTapActionButton notification: GameNotification) {

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
