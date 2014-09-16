//
//  ProfileViewController.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 9/12/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var inGameNameEditTextField: UITextField!
    
    @IBOutlet weak var profilePicView: AvatarRoundedView!
    private var defaultText:String!
    
    @IBOutlet weak var rankViewButton: DesignableButton!
    
    private var closedChallenges: [Game] = []
    
    private var user = NetworkClient.sharedClient.authenticatedUser
    
    private var imagePicker:UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        return picker
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadClosedChallenges()
        self.tableView.registerNib(UINib(nibName: "ChallengesTimelineTableViewCell", bundle: nil), forCellReuseIdentifier: kTHChallengesTimelineTableViewCellIdentifier)
        tableView.alwaysBounceVertical = false
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
                if strongSelf.closedChallenges.count > 0 {
                    strongSelf.tableView.hidden =  true
                } else {
                    strongSelf.tableView.hidden =  false
                }
                
                hud.dismissAnimated(true)
            }
        }
    }
    
    @IBAction func imageTapped(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "Change display picture", message: "Select a photo from the library or take a new one.", preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        weak var weakSelf = self
        
        let takePhotoAction = UIAlertAction(title: "Take photo", style: .Default) {
            a in
            if let strongSelf = weakSelf {
                let picker = strongSelf.imagePicker
                picker.sourceType = .Camera
                strongSelf.presentViewController(picker, animated: true, completion: nil)
            }
        }
        
        let chooseFromlibraryAction = UIAlertAction(title: "Choose existing", style: .Default) {
            a in
            if let strongSelf = weakSelf {
                let picker = strongSelf.imagePicker
                picker.sourceType = .PhotoLibrary
                strongSelf.presentViewController(picker, animated: true, completion: nil)
            }
        }
        
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(takePhotoAction)
        actionSheet.addAction(chooseFromlibraryAction)
        self.presentViewController(actionSheet, animated: true, completion: nil)
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
        
    //MARK:- UIImagePickerControllerDelegate methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        picker.dismissViewControllerAnimated(true) {
            [unowned self] in
            if let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
                self.profilePicView.image = selectedImage
            }
            
        }
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
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
