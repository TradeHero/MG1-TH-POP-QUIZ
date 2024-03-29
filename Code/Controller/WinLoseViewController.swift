//
//  WinLoseViewController.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 7/31/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class WinLoseViewController: UIViewController {

    @IBOutlet weak var THDollarWonLabel: UILabel!
    @IBOutlet private weak var winLoseLabel: UILabel!

    @IBOutlet private weak var winLoseBackgroundImageView: UIImageView!

    @IBOutlet private weak var winLoseSmileyIcon: UIImageView!

    @IBOutlet private weak var winningRay: UIImageView!

    @IBOutlet private weak var losingRay: UIImageView!

    //MARK:-
    @IBOutlet private weak var largeBoxBackground: UIImageView!

    @IBOutlet private weak var largeBoxAvatarView: AvatarRoundedView!

    @IBOutlet private weak var largeBoxNameLabel: UILabel!

    @IBOutlet private weak var largeBoxScoreLabel: UILabel!

    @IBOutlet private weak var smallBoxBackground: UIImageView!

    @IBOutlet private weak var smallBoxAvatarView: AvatarRoundedView!

    @IBOutlet private weak var smallBoxNameLabel: UILabel!

    @IBOutlet private weak var smallBoxScoreLabel: UILabel!

    @IBOutlet private var starViews: [UIImageView]!

    private var game: Game!

    private var selfScore = 0

    private var opponentScore = 0

    private var selfUser: User!
    private var opponentUser: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        let differenceInScore = selfScore - opponentScore
        let dStr = NSNumberFormatter.localizedStringFromNumber(NSNumber(integer: differenceInScore), numberStyle: .DecimalStyle)
        if differenceInScore > 0 {
            THDollarWonLabel.text = "TH$ " + dStr
        } else {
            THDollarWonLabel.text = "TH$ 0"
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.hideNavigationBar()
        animateStars()
    }


    @IBAction func showResultAction(sender: AnyObject) {
        self.performSegueWithIdentifier("CompleteQuizResultSegue", sender: self)
    }

    func animateStars() {
        for star in starViews {
            var b = star.bounds
            var b2 = b
            b.size = CGSizeZero
            star.bounds = b

            UIView.animateWithDuration(0.2) {
                star.bounds = b2
            }
        }
    }

    private func configureAsWinningScene() {
        winLoseLabel.text = "YOU WON!"
        for star in starViews {
            star.alpha = 1
        }
        winLoseBackgroundImageView.image = UIImage(named: "WinSceneBackground")
        largeBoxBackground.image = UIImage(named: "WinBoxBackground")
        winLoseSmileyIcon.image = UIImage(named: "WinSmileyIcon")

        smallBoxBackground.image = UIImage(named: "LoseBoxBackground")
        winningRay.alpha = 1
        losingRay.alpha = 0
    }

    private func configureAsLosingScene() {
        winLoseLabel.text = "YOU LOST!"
        for star in starViews {
            star.alpha = 0
        }
        winLoseBackgroundImageView.image = UIImage(named: "LoseSceneBackground")
        largeBoxBackground.image = UIImage(named: "LoseBoxBackground")
        winLoseSmileyIcon.image = UIImage(named: "LoseSmileyIcon")
        smallBoxBackground.image = UIImage(named: "WinBoxBackground")

        winningRay.alpha = 0
        losingRay.alpha = 1
    }

    func bindResult(game: Game, selfUser: User, opponentUser: User) {
        self.game = game

        self.selfUser = selfUser
        self.opponentUser = opponentUser

        var selfResult: GameResult!
        var oppResult: GameResult!
        if game.challenger.userId == selfUser.userId {
            selfResult = game.challengerResult
            oppResult = game.opponentResult
        } else {
            selfResult = game.opponentResult
            oppResult = game.challengerResult
        }

        for extraDetail in selfResult.finalResultDetails! {
            selfScore += extraDetail.finalScore
        }

        for extraDetail in oppResult.finalResultDetails! {
            opponentScore += extraDetail.finalScore
        }

    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "CompleteQuizResultSegue" {
            let vc = segue.destinationViewController as ResultsViewController
            vc.bindGame(self.game)
        }

    }

    private func configureUI() {
        if selfScore > opponentScore {
            configureAsWinningScene()
        } else {
            configureAsLosingScene()
        }

        largeBoxNameLabel.text = selfUser.displayName
        //        largeBoxRankLabel = selfUser.rank
        //        largeBoxLevelLabel.text = selfUser.level
        largeBoxScoreLabel.text = "\(selfScore.decimalFormattedString)"
        smallBoxNameLabel.text = opponentUser.displayName
        //        smallBoxRankLabel = opponentUser.rank
        //        smallBoxLevelLabel.text = opponentUser.level
        smallBoxScoreLabel.text = "\(opponentScore.decimalFormattedString)"
        NetworkClient.fetchImageFromURLString(selfUser.pictureURL, progressHandler: nil) {
            (image, error) in
            self.largeBoxAvatarView.image = image
        }

        NetworkClient.fetchImageFromURLString(opponentUser.pictureURL, progressHandler: nil) {
            (image, error) in
            self.smallBoxAvatarView.image = image
        }

    }
}
