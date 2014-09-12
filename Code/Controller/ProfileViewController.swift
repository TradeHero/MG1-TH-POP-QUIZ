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

    @IBOutlet weak var inGameNameEditTextField: UITextField!
    private var defaultText:String!
    
    @IBOutlet weak var rankViewButton: DesignableButton!
    
    private var closedChallenges: [Game]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadClosedChallenges()
        
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
    
    func loadClosedChallenges() {
        weak var weakSelf = self
        
        
        NetworkClient.sharedClient.fetchClosedChallenges() {
            if let strongSelf = weakSelf {
                strongSelf.closedChallenges = $0
                strongSelf.closedChallenges.sort() {
                    $0.createdAt.timeIntervalSinceReferenceDate > $1.createdAt.timeIntervalSinceReferenceDate
                }
            }
        }
    }
    
    @IBAction func imageTapped(sender: AnyObject) {
        println("tapped")
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
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
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
