//
//  ResultsViewController.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 9/2/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, QuestionResultTableViewCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet private weak var categoryNameLabel: UILabel!
    @IBOutlet private weak var categoryLogoImageView: UIImageView!
    
    //self
    @IBOutlet private weak var selfAvatarView: AvatarRoundedView!
    @IBOutlet private weak var selfDispNameLabel: UILabel!
    @IBOutlet private weak var selfRankLabel: UILabel!
    @IBOutlet private weak var selfLevelLabel: UILabel!
    
    //opponent
    @IBOutlet private weak var opponentAvatarView: AvatarRoundedView!
    @IBOutlet private weak var opponentDisplayNameLabel: UILabel!
    @IBOutlet private weak var opponentRankLabel: UILabel!
    @IBOutlet private weak var opponentLevelLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: "QuestionResultTableViewCell", bundle: nil), forCellReuseIdentifier: kTHQuestionResultTableViewCellIdentifier)
        self.loadResults()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.hideNavigationBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func nextAction() {
        
    }
    
    func loadResults(){
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "")
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView! {
        return nil
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func questionResultCell(cell: QuestionResultTableViewCell, didTapInfoButton questionID: Int) {
        
    }
    
    //MARK:- Private functions
    private func createHeaderViewForResultsView() -> UIView {
        let view = UIView(frame: CGRectMake(0, 0, 285, 50))
        view.backgroundColor = UIColor(hex: 0xFF4069)
        var label = UILabel(frame:CGRectMake(15, 14, 130, 21))
        label.text = "Correct Answers"
        view.addSubview(label)
        
        var selfAvatarView = AvatarRoundedView(frame: CGRectMake(161, 2, 45, 45))
        view.addSubview(selfAvatarView)
        NetworkClient.fetchImageFromURLString("", progressHandler: nil) {
            (image, error) in
            if let e = error {
                println(e)
                return
            }
            selfAvatarView.image = image
        }
    
        var opponentAvatarView = AvatarRoundedView(frame: CGRectMake(232, 2, 45, 45))
        view.addSubview(selfAvatarView)
        NetworkClient.fetchImageFromURLString("", progressHandler: nil) {
            (image, error) in
            if let e = error {
                println(e)
                return
            }
            opponentAvatarView.image = image
        }
        view.roundCornersOnTopLeft(true, topRight: true, bottomLeft: false, bottomRight: false, radius: 1.0)
        return view
    }
}
