//
//  ProfileViewController.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 9/12/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource
{

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var inGameNameEditTextField: UITextField!
    
    @IBOutlet weak var profilePicView: AvatarRoundedView!
    private var defaultText:String!
    
    @IBOutlet weak var rankViewButton: DesignableButton!
    
    private var closedChallenges: [Game]!
    
    private var user = NetworkClient.sharedClient.authenticatedUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.loadClosedChallenges()
        self.tableView.registerNib(UINib(nibName: "ChallengesTimelineTableViewCell", bundle: nil), forCellReuseIdentifier: kTHChallengesTimelineTableViewCellIdentifier)
        self.configureUI()
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
    func loadClosedChallenges() {
        weak var weakSelf = self
        var hud = JGProgressHUD.progressHUDWithCustomisedStyleInView(self.view)
        hud.textLabel.text = "Refreshing timeline.."
        NetworkClient.sharedClient.fetchClosedChallenges {
            if let strongSelf = weakSelf {
                strongSelf.closedChallenges = $0
                strongSelf.closedChallenges.sort {
                    $0.createdAt.timeIntervalSinceReferenceDate > $1.createdAt.timeIntervalSinceReferenceDate
                }
                
                strongSelf.tableView.reloadData()
                hud.dismissAnimated(true)
            }
        }
    }
    
    @IBAction func imageTapped(sender: AnyObject) {
        
    }

    private func configureUI() {
        weak var weakSelf = self
        NetworkClient.fetchImageFromURLString(user.pictureURL, progressHandler: nil) {
            image, error in
            if error != nil {
                println(error)
            }
            if let strongSelf = weakSelf {
                strongSelf.profilePicView.image  = image
            }
        }
        
        self.inGameNameEditTextField.text = user.displayName
    }
    // MARK:- UITextField delegate methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text == defaultText || countElements(textField.text) <= 0{
            return false
        }
        
        //TODO: update in game name
        NetworkClient.sharedClient.updateInGameName(textField.text) {
            
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        defaultText = textField.text
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.text = defaultText
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        inGameNameEditTextField.text = defaultText
        self.view.endEditing(true)
    }
    
    // MARK:- UITextField delegate methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kTHChallengesTimelineTableViewCellIdentifier) as ChallengesTimelineTableViewCell
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
