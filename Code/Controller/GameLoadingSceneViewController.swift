//
//  GameLoadingSceneViewController.swift
//  TH PopQuiz
//
//  Created by Ryne Cheow on 8/29/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class GameLoadingSceneViewController: UIViewController {

    @IBOutlet private weak var countdownTimerLabel: UILabel!
    @IBOutlet private weak var prepareView: UIView!
    @IBOutlet private weak var prepareViewLabel: UILabel!
    @IBOutlet private weak var prepareViewDetailLabel: UILabel!
    // top view

    @IBOutlet weak var upperView: UIView!
    @IBOutlet private weak var topBoxBackgroundImageView: UIImageView!
    @IBOutlet private weak var categoryIconImageView: UIImageView!
    @IBOutlet private weak var categoryNameLabel: UILabel!

    @IBOutlet private weak var selfAvatarView: AvatarRoundedView!
    @IBOutlet private weak var selfDisplayNameLabel: UILabel!

    @IBOutlet weak var upperviewTrailingSpaceToSuperview: NSLayoutConstraint!
    @IBOutlet weak var upperviewLeadingSpaceToSuperview: NSLayoutConstraint!
    // bottom view

    @IBOutlet weak var lowerView: UIView!
    @IBOutlet private weak var bottomBoxBackgroundImageView: UIImageView!
    @IBOutlet private weak var opponentAvatarView: AvatarRoundedView!
    @IBOutlet private weak var opponentDisplayNameLabel: UILabel!

    @IBOutlet weak var roundTimerImageView: UIImageView!

    @IBOutlet weak var countdownTimerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var countdownTimerHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var lowerviewLeadingSpaceToSuperview: NSLayoutConstraint!

    @IBOutlet weak var lowerViewTrailingSpaceToSuperview: NSLayoutConstraint!
    private var user = NetworkClient.sharedClient.user
    private var game: Game!

    private var player: User!
    private var opponent: User!

    private var timer: NSTimer!
    private var startTime: NSDate!

    private var time = 4

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.hideNavigationBar()
        self.configureUI()

        self.prepareGame(self.game) {
            [unowned self] in
            self.prepareViewDetailLabel.text = "Done fetching image."
            UIView.animateWithDuration(1.0, delay: 0, options: .TransitionCrossDissolve, animations: {
                self.prepareView.alpha = 0
            }) {
                [unowned self] complete in
                if complete {
                    UIView.animateWithDuration(1, options: .TransitionCrossDissolve) {
                        self.opponentAvatarView.alpha = 1
                        self.opponentDisplayNameLabel.alpha = 1
                    }
                    self.timerStart()
                }
            }
        }
        // Do any additional setup after loading the view.
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func bindGame(game: Game) {
        self.game = game
        self.player = game.selfUser
        self.opponent = game.awayUser
//        self.determineUserRoles(game)
    }

    private func determineUserRoles(game: Game) {
        if game.challenger.userId == user.userId {
            player = game.challenger
            opponent = game.opponentUser
        } else if game.opponentUser.userId == user.userId {
            player = game.opponentUser
            opponent = game.challenger
        } else {
            print("Shouldn't happen")
        }
    }

    private func prepareGame(game: Game, completionHandler: () -> ()) {
        var qSet = game.questionSet
        var count: Int = 0
        var tcount = game.questionSet.count
        for q in qSet {
            q.fetchImage {
                [unowned self] in
                count += 1
                self.prepareViewDetailLabel.text = "\(count) of \(tcount)"
                if count == game.questionSet.count {
                    self.game = game
                    completionHandler()
                }
            }
        }
    }

    private func timerStart() {
        if timer == nil {
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateTimer", userInfo: nil, repeats: true)
        }
    }


    func updateTimer() {
        countdownTimerLabel.text = String(--time)
        if time == 0 {
            timer.invalidate()
            timer = nil
            startGame()
        }
    }

    private func startGame() {
        self.upperviewLeadingSpaceToSuperview.constant += 1000
        self.upperviewTrailingSpaceToSuperview.constant -= 1000
        self.lowerviewLeadingSpaceToSuperview.constant -= 1000
        self.lowerViewTrailingSpaceToSuperview.constant += 1000

        self.countdownTimerWidthConstraint.constant = 0
        self.countdownTimerHeightConstraint.constant = 0
        self.view.setNeedsUpdateConstraints()
        self.upperView.setNeedsUpdateConstraints()
        self.lowerView.setNeedsUpdateConstraints()
        UIView.animateWithDuration(1, delay: 1, options: .TransitionNone, animations: {
            [unowned self] in
            self.countdownTimerLabel.alpha = 0
            self.view.layoutIfNeeded()
        }) {
            [unowned self] complete in
            if complete {
                usleep(1)
                self.performSegueWithIdentifier("PresentQuizSegue", sender: self)
            }
        }
    }

    private func configureUI() {
        self.opponentAvatarView.alpha = 0
        self.opponentDisplayNameLabel.alpha = 0

        NetworkClient.fetchImageFromURLString(player.pictureURL, progressHandler: nil) {
            [unowned self] image, error in

            if let err = error {
                print(err)
            }
            self.selfAvatarView.image = image
        }
        self.selfDisplayNameLabel.text = player.displayName

        NetworkClient.fetchImageFromURLString(opponent.pictureURL, progressHandler: nil) {
            [unowned self] image, error in

            if let err = error {
                print(err)
            }
            self.opponentAvatarView.image = image
        }
        self.opponentDisplayNameLabel.text = opponent.displayName
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "PresentQuizSegue" {
            let vc = segue.destinationViewController as! QuizViewController
            vc.bindGameAndUsers(self.game, player: self.player, opponent: self.opponent)
        }
    }


}
