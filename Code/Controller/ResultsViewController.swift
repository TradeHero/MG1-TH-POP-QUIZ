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
    @IBOutlet private weak var opponentWaitingImageView: UIImageView!
    
    @IBOutlet weak var nextOrRematchButton: UIButton!
    private var game: Game!
    
    private var player: THUser!
    private var opponent: THUser!
    
    private var playerResult: GameResult!
    private var opponentResult: GameResult!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if game.isGameCompletedByBothPlayer {
            nextOrRematchButton.setTitle("Rematch", forState: .Normal)
        } else {
            nextOrRematchButton.setTitle("Home", forState: .Normal)
        }
        self.tableView.registerNib(UINib(nibName: "QuestionResultTableViewCell", bundle: nil), forCellReuseIdentifier: kTHQuestionResultTableViewCellIdentifier)
        self.tableView.registerNib(UINib(nibName: "GameResultDetailTableViewCell", bundle: nil), forCellReuseIdentifier: kTHGameResultDetailTableViewCellIdentifier)
        self.loadResults()
        self.configureUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.hideNavigationBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func rematchAction() {
        weak var weakSelf = self
        
        if game.isGameCompletedByBothPlayer {
            var hud = JGProgressHUD.progressHUDWithCustomisedStyleInView(self.view)
            hud.textLabel.text = "Re-matching..."
            hud.detailTextLabel.text = "Creating game with user.."
            NetworkClient.sharedClient.createChallenge(numberOfQuestions: 7, opponentId: opponent.userId) {
                var strongSelf = weakSelf!
                if let g = $0 {
                    hud.dismissAnimated(true)
                    let vc = UIStoryboard.quizStoryboard().instantiateViewControllerWithIdentifier("GameLoadingSceneViewController") as GameLoadingSceneViewController
                    vc.bindGame($0)
                    strongSelf.navigationController?.pushViewController(vc, animated: true)
                }
            }
        } else {
            self.navigationController?.showNavigationBar()
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
    func bindGame(game:Game){
        self.game = game
        self.determineUserRoles(game)
    }
    
    private func configureUI() {
        selfDispNameLabel.text = self.player.displayName
        if game.isGameCompletedByBothPlayer {
            opponentWaitingImageView.alpha = 0
        } else {
             opponentWaitingImageView.alpha = 1
        }
        weak var wself = self
        NetworkClient.fetchImageFromURLString(player.pictureURL, progressHandler: nil) {
            (image, error) in
            var sself = wself!
            if let e = error {
                println(e)
                return
            }
            sself.selfAvatarView.image = image
        }

        
        opponentDisplayNameLabel.text = self.opponent.displayName
        NetworkClient.fetchImageFromURLString(opponent.pictureURL, progressHandler: nil) {
            (image, error) in
            var sself = wself!
            if let e = error {
                println(e)
                return
            }
            sself.opponentAvatarView.image = image
        }
    }
    private func determineUserRoles(game:Game) {
        let user = NetworkClient.sharedClient.authenticatedUser
        if game.initiatingPlayer.userId == user.userId {
            player = game.initiatingPlayer
            playerResult = game.initiatingPlayerResult
            opponent = game.opponentPlayer
            opponentResult = game.opponentPlayerResult
        } else {
            player = game.opponentPlayer
            playerResult = game.opponentPlayerResult
            opponent = game.initiatingPlayer
            opponentResult = game.initiatingPlayerResult
        }
    }

    func loadResults(){
//        selfQuestionResults.removeAll(keepCapacity: true)
//        oppQuestionResults.removeAll(keepCapacity: true)
        self.tableView.reloadDataAnimateWithWave(.LeftToRight)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(kTHQuestionResultTableViewCellIdentifier, forIndexPath: indexPath) as QuestionResultTableViewCell
            let selfRaw = playerResult.resultDetails[indexPath.row]
            var selfRes = QuestionResult(questionID: selfRaw.id, timeTaken: selfRaw.time, correct: selfRaw.rawScore > 0, score: selfRaw.rawScore)
            
            if let selfExtras = playerResult.resultExtraDetails {
                selfRes.finalScore = playerResult.finalScore
            }
            
            var oppRes: QuestionResult!
            if let oResult = opponentResult {
                let oppRaw = oResult.resultDetails[indexPath.row]
                oppRes = QuestionResult(questionID: oppRaw.id, timeTaken: oppRaw.time, correct: oppRaw.rawScore > 0, score: oppRaw.rawScore)
                
                if let oppExtras = opponentResult.resultExtraDetails {
                    oppRes.finalScore = opponentResult.finalScore
                }
            }
            
            cell.bindQuestionResults(selfRes, opponentResult: oppRes, index:indexPath.row+1)
            cell.layoutIfNeeded()
            cell.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier(kTHGameResultDetailTableViewCellIdentifier) as GameResultDetailTableViewCell
            cell.attribute = "Hints Used"
            cell.selfAttributeDetail = "\(playerResult.hintsUsed)"
            cell.labelTintColor = UIColor(hex: 0xBF0221)
            

            cell.opponentAttributeDetail = game.isGameCompletedByBothPlayer ? "\(opponentResult.hintsUsed)" : "--"
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier(kTHGameResultDetailTableViewCellIdentifier) as GameResultDetailTableViewCell
            cell.attribute = "Highest Combo"
            cell.selfAttributeDetail = "\(playerResult.highestCombo)"
            
            cell.labelTintColor = UIColor(hex: 0x457B1D)
            cell.opponentAttributeDetail = game.isGameCompletedByBothPlayer ? "\(opponentResult.highestCombo)" : "--"
            return cell
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier(kTHGameResultDetailTableViewCellIdentifier) as GameResultDetailTableViewCell
            cell.attribute = "Total Score"
            cell.selfAttributeDetail = "\(playerResult.finalScore)"
            cell.opponentAttributeDetail = game.isGameCompletedByBothPlayer ? "\(opponentResult.finalScore.decimalFormattedString)" : "--"
            return cell
        default:
            return UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "")
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0, 1, 2, 3:
            return 42
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.game.questionSet.count
        case 1, 2, 3:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return createHeaderViewForResultsView()
        default:
            return nil
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 50
        default:
            return 0
        }
    }
    
    func questionResultCell(cell: QuestionResultTableViewCell, didTapInfoButton questionID: Int) {
        
    }
    
    //MARK:- Private functions
    private func createHeaderViewForResultsView() -> UIView {
        let view = UIView(frame: CGRectMake(0, 0, 285, 50))
        
        view.backgroundColor = UIColor(hex: 0xFF4069)
        view.layer.cornerRadius = 10.0
        view.layer.borderWidth = 3.0
        view.layer.borderColor = UIColor(hex: 0xF51B49).CGColor

        var label = UILabel(frame:CGRectMake(8, 14, 130, 21))
        label.text = "Correct Answers"
        label.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
        label.textColor = UIColor.whiteColor()
        view.addSubview(label)
        
        var selfAvatarView = AvatarRoundedView(frame: CGRectMake(152, 5, 40, 40))
        selfAvatarView.borderWidth = 1
        selfAvatarView.borderColor = UIColor.whiteColor()
        view.addSubview(selfAvatarView)
        NetworkClient.fetchImageFromURLString(player.pictureURL, progressHandler: nil) {
            (image, error) in
            if let e = error {
                println(e)
                return
            }
            selfAvatarView.image = image
        }
    
        var opponentAvatarView = AvatarRoundedView(frame: CGRectMake(223, 5, 40, 40))
        view.addSubview(opponentAvatarView)
        opponentAvatarView.borderWidth = 1
        opponentAvatarView.borderColor = UIColor.whiteColor()
        NetworkClient.fetchImageFromURLString(opponent.pictureURL, progressHandler: nil) {
            (image, error) in
            if let e = error {
                println(e)
                return
            }
            opponentAvatarView.image = image
        }
//        view.roundCornersOnTopLeft(true, topRight: true, bottomLeft: false, bottomRight: false, radius: 5.0)
        return view
    }
}
