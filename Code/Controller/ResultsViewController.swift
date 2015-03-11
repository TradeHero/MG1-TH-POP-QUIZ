//
//  ResultsViewController.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 9/2/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import JGProgressHUD

class ResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, QuestionResultTableViewCellDelegate {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet private weak var categoryNameLabel: UILabel!
    @IBOutlet private weak var categoryLogoImageView: UIImageView!

    //self
    @IBOutlet private weak var selfAvatarView: AvatarRoundedView!
    @IBOutlet private weak var selfDispNameLabel: UILabel!

    //opponent
    @IBOutlet private weak var opponentAvatarView: AvatarRoundedView!
    @IBOutlet private weak var opponentDisplayNameLabel: UILabel!
    @IBOutlet private weak var opponentWaitingImageView: UIImageView!

    @IBOutlet weak var nextOrRematchButton: UIButton!
    private var game: Game!

    private var player: User!
    private var opponent: User!

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
        if game.isGameCompletedByBothPlayer {
            var hud = JGProgressHUD.progressHUDWithDefaultStyle()
            hud.showInWindow()

            hud.textLabel.text = "Re-matching..."
            hud.detailTextLabel.text = "Creating game with user.."
            NetworkClient.sharedClient.createChallenge(numberOfQuestions: 7, opponentId: opponent.userId, { error in debugPrintln(error) }) {
                [unowned self] in
                hud.dismissAnimated(true)
                let vc = UIStoryboard.quizStoryboard().instantiateViewControllerWithIdentifier("GameLoadingSceneViewController") as GameLoadingSceneViewController
                vc.bindGame($0)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            self.navigationController?.showNavigationBar()
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }

    func bindGame(game: Game) {
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
        NetworkClient.fetchImageFromURLString(player.pictureURL, progressHandler: nil) {
            [unowned self] (image, error) in

            if let e = error {
                println(e)
                return
            }
            self.selfAvatarView.image = image
        }


        opponentDisplayNameLabel.text = self.opponent.displayName
        NetworkClient.fetchImageFromURLString(opponent.pictureURL, progressHandler: nil) {
            [unowned self] (image, error) in
            if let e = error {
                println(e)
                return
            }
            self.opponentAvatarView.image = image
        }
    }

    private func determineUserRoles(game: Game) {
        let user = NetworkClient.sharedClient.user
        if game.challenger.userId == user.userId {
            player = game.challenger
            playerResult = game.challengerResult
            opponent = game.opponentUser
            opponentResult = game.opponentResult
        } else {
            player = game.opponentUser
            playerResult = game.opponentResult
            opponent = game.challenger
            opponentResult = game.challengerResult
        }
    }

    func loadResults() {
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
            var selfRes = QuestionResult(questionID: selfRaw.questionId, timeTaken: selfRaw.timeTaken, correct: selfRaw.rawScore > 0, score: selfRaw.rawScore)

            if let selfExtras = playerResult.finalResultDetails {
                selfRes.finalScore = playerResult.finalScore
            }

            var oppRes: QuestionResult!
            if let oResult = opponentResult {
                let oppRaw = oResult.resultDetails[indexPath.row]
                oppRes = QuestionResult(questionID: oppRaw.questionId, timeTaken: oppRaw.timeTaken, correct: oppRaw.rawScore > 0, score: oppRaw.rawScore)

                if let oppExtras = opponentResult.finalResultDetails {
                    oppRes.finalScore = opponentResult.finalScore
                }
            }

            cell.bindQuestionResults(selfRes, opponentResult: oppRes, index: indexPath.row + 1)
            cell.layoutIfNeeded()
            cell.delegate = self

            if indexPath.row == playerResult.resultDetails.count - 1 {
                UIView.roundView(cell, onCorner: .BottomLeft | .BottomRight, radius: 5)
            }
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
            cell.selfAttributeDetail = "\(playerResult.correctStreak)"

            cell.labelTintColor = UIColor(hex: 0x457B1D)
            cell.opponentAttributeDetail = game.isGameCompletedByBothPlayer ? "\(opponentResult.correctStreak)" : "--"

            return cell
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier(kTHGameResultDetailTableViewCellIdentifier) as GameResultDetailTableViewCell
            cell.attribute = "Total Score"
            cell.selfAttributeDetail = "\(playerResult.finalScore!.decimalFormattedString)"
            cell.opponentAttributeDetail = game.isGameCompletedByBothPlayer ? "\(opponentResult.finalScore!.decimalFormattedString)" : "--"


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
            let view = createHeaderViewForResultsView()
//            UIView.roundView(view, onCorner: .TopLeft | .TopRight, radius: 5)
            return view
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
    private func createHeaderViewForResultsView() -> UITableViewHeaderFooterView {
        let view = UITableViewHeaderFooterView.newAutoLayoutView()
        view.frame = CGRectMake(0, 0, 285, 50)

        view.contentView.backgroundColor = UIColor(hex: 0xFF4069)

        var label = UILabel(frame: CGRectMake(8, 14, 130, 21))
        label.text = "Correct Answers"
        label.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
        label.textColor = UIColor.whiteColor()
        view.contentView.addSubview(label)

        var selfAvatarView = AvatarRoundedView(frame: CGRectMake(152, 5, 40, 40))
        selfAvatarView.borderWidth = 1
        selfAvatarView.borderColor = UIColor.whiteColor()
        view.contentView.addSubview(selfAvatarView)

        NetworkClient.fetchImageFromURLString(player.pictureURL, progressHandler: nil) {
            (image, error) in
            if let e = error {
                println(e)
                return
            }
            selfAvatarView.image = image
        }

        var opponentAvatarView = AvatarRoundedView(frame: CGRectMake(223, 5, 40, 40))
        view.contentView.addSubview(opponentAvatarView)
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
        return view
    }
}
