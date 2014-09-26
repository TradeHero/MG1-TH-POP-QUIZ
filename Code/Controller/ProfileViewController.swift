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

    @IBOutlet private weak var profileUpdateButton: UIButton!
    
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private weak var inGameNameEditTextField: UITextField!
    
    @IBOutlet private weak var profilePicView: AvatarRoundedView!
    
    private var defaultText:String!
    
    @IBOutlet private weak var rankViewButton: DesignableButton!
    
    private var closedChallenges: [Game] = []
    
    private var user = NetworkClient.sharedClient.user
    
    private var imagePicker:UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        return picker
    }
    
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
        self.profileUpdateButton.disable()
    }
    
    func loadClosedChallenges() {
        weak var weakSelf = self
        
        var hud = JGProgressHUD.progressHUDWithCustomisedStyleInView(self.view)
        hud.textLabel.text = "Refreshing timeline.."
        NetworkClient.sharedClient.fetchClosedChallenges {
            if let strongSelf = weakSelf {
                var c = $0
                c.sort {
                    $1.createdAt.timeIntervalSinceReferenceDate > $0.createdAt.timeIntervalSinceReferenceDate
                }
                
                strongSelf.closedChallenges = c
                strongSelf.tableView.reloadData()
                
                let shouldNotHideTableViewForEmptyView = c.count > 0
                strongSelf.tableView.hidden = !shouldNotHideTableViewForEmptyView
                strongSelf.emptyTimelineView.hidden = shouldNotHideTableViewForEmptyView
                
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
        
        //Empty timeline view
        self.view.addSubview(emptyTimelineView)
        
        self.emptyTimelineView.setNeedsUpdateConstraints()
        self.emptyTimelineView.updateConstraintsIfNeeded()
        
        UIView.autoSetPriority(750) {
//            self.emptyTimelineView.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
        }
        
        self.emptyTimelineView.autoConstrainAttribute(NSLayoutAttribute.CenterX.toRaw(), toAttribute: NSLayoutAttribute.CenterX.toRaw(), ofView: self.emptyTimelineView.superview, withMultiplier: 1)
        self.emptyTimelineView.autoConstrainAttribute(NSLayoutAttribute.CenterY.toRaw(), toAttribute: NSLayoutAttribute.CenterY.toRaw(), ofView: self.emptyTimelineView.superview, withMultiplier: 1)
        self.emptyTimelineView.autoSetDimensionsToSize(CGSizeMake(258, 284))
    }
    // MARK:- UITextField delegate methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text == self.user.displayName || countElements(textField.text) <= 0 {
            return false
        }
        profileUpdateButton.enabled = self.user.displayName != textField.text
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
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
        
    //MARK:- UIImagePickerControllerDelegate methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        picker.dismissViewControllerAnimated(true) {
            [unowned self] in
            if let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
                self.profilePicView.image = selectedImage
            }
            self.profileUpdateButton.enable()
        }
    }
    //MARK:- UINavigationControllerDelegate methods
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
    }
}
