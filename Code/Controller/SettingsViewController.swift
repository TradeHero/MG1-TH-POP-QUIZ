//
//  SettingsViewController.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 9/15/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, SettingsControlTableViewCellDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet private weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: "SettingsControlTableViewCell", bundle: nil), forCellReuseIdentifier: kTHSettingsControlTableViewCellIdentifier)
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func logoutAction(sender: AnyObject) {
        let alertView = UIAlertController(title: "Logout", message: "Are you sure you want to log out?", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default) {
            action in
            NetworkClient.sharedClient.logout()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertView.addAction(okAction)
        alertView.addAction(cancelAction)
        
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    //MARK:- SettingsControlTableViewCellDelegate methods
    func settingsControlTableViewCell(cell: SettingsControlTableViewCell, didToggleSwitch on: Bool) {
        if let type = cell.type {
            switch type {
            case .PushNotification:
                kTHPushNotificationOn = on
            case .VibrationEffect:
                kTHVibrationEffectOn = on
            default:
                break
            }
        }
    }

    func settingsControlTableViewCell(cell: SettingsControlTableViewCell, didSliderValueChanged value: Float) {
        if let type = cell.type {
            switch type {
            case .BackgroundMusic:
                kTHBackgroundMusicValue = value
            case .SoundEffect:
                kTHSoundEffectValue = value
            default:
                break
            }
        }
    }
    
    //MARK:- UITableViewDelegate, UITableViewDataSource methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kTHSettingsControlTableViewCellIdentifier) as SettingsControlTableViewCell
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.configureControlType(.PushNotification)
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                cell.configureControlType(.BackgroundMusic)
            case 1:
                cell.configureControlType(.SoundEffect)
            case 2:
                cell.configureControlType(.VibrationEffect)
            default:
                break
            }
        default:
            break
        }
        cell.layoutIfNeeded()
        cell.delegate = self
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        default:
            return 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 42
    }
}
