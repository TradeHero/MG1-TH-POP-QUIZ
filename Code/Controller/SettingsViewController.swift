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
        self.tableView.registerNib(UINib(nibName: "SettingsSliderTableViewCell", bundle: nil), forCellReuseIdentifier: kTHSettingsSliderTableViewCellIdentifier)
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

    func settingsSliderTableViewCell(cell: SettingsSliderTableViewCell, didSliderValueChanged value: Float) {
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
        var cell = UITableViewCell()
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCellWithIdentifier(kTHSettingsControlTableViewCellIdentifier) as UITableViewCell
                (cell as SettingsControlTableViewCell).configureControlType(.PushNotification)
                (cell as SettingsControlTableViewCell).delegate = self
                UIView.roundView(cell, onCorner: .BottomLeft | .BottomRight, radius: 5)
                return cell
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCellWithIdentifier(kTHSettingsSliderTableViewCellIdentifier) as UITableViewCell
                (cell as SettingsSliderTableViewCell).configureControlType(.BackgroundMusic)
                (cell as SettingsSliderTableViewCell).delegate = self
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier(kTHSettingsSliderTableViewCellIdentifier) as UITableViewCell
                (cell as SettingsSliderTableViewCell).configureControlType(.SoundEffect)
                (cell as SettingsSliderTableViewCell).delegate = self
                return cell
            case 2:
                cell = tableView.dequeueReusableCellWithIdentifier(kTHSettingsControlTableViewCellIdentifier) as UITableViewCell
                (cell as SettingsControlTableViewCell).configureControlType(.VibrationEffect)
                (cell as SettingsControlTableViewCell).delegate = self
                UIView.roundView(cell, onCorner: .BottomLeft | .BottomRight, radius: 5)
                return cell
            default:
                break
            }
        default:
            break
        }
        
        cell.layoutIfNeeded()
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
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return 42
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0, 1:
                return 70
            case 2:
                return 42
            default:
                break
            }
        default:
            break
        }
        return 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return createHeaderView("Notifications")
        case 1:
            return createHeaderView("In Game Settings")
        default:
            return nil
        }
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    private func createHeaderView(title:String) -> UIView{
        var view = UIView(frame: CGRectMake(0, 0, 286, 40))
        UIView.roundView(view, onCorner: .TopRight | .TopLeft, radius: 10)
        
        view.backgroundColor = UIColor(hex: 0xFF4069)
        let label = UILabel(frame: CGRectMake(8, 9, 152, 21))
        label.text = title
        label.font = UIFont(name: "AvenirNext-Regular", size: 15)
        label.textColor = UIColor.whiteColor()
        view.addSubview(label)
        return view
    }
}
