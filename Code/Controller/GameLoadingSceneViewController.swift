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
    
    @IBOutlet private weak var topBoxBackgroundImageView: UIImageView!
    @IBOutlet private weak var categoryIconImageView: UIImageView!
    @IBOutlet private weak var categoryNameLabel: UILabel!
    
    @IBOutlet private weak var selfAvatarView: AvatarRoundedView!
    @IBOutlet private weak var selfDisplayNameLabel: UILabel!
    @IBOutlet private weak var selfRankLabel: UILabel!
    @IBOutlet private weak var selfLevelLabel: UILabel!
    @IBOutlet private weak var selfBadgeImageView: UIImageView!
    
    // bottom view
    
    @IBOutlet private weak var bottomBoxBackgroundImageView: UIImageView!
    @IBOutlet private weak var opponentAvatarView: AvatarRoundedView!
    @IBOutlet private weak var opponentDisplayNameLabel: UILabel!
    @IBOutlet private weak var opponentRankLabel: UILabel!
    @IBOutlet private weak var opponentLevelLabel: UILabel!
    @IBOutlet private weak var opponentBadgeImageView: UIImageView!
    
    @IBOutlet weak var roundTimerImageView: UIImageView!
    private var user = NetworkClient.sharedClient.user
    private var game: Game!
    
    private var player: THUser!
    private var opponent: THUser!
    
    private var timer: NSTimer!
    private var startTime: NSDate!
    
    private var time = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.hideNavigationBar()
        self.configureUI()
        
        weak var wself = self
        self.prepareGame(self.game){
            var sself = wself!
            sself.prepareViewDetailLabel.text = "Done fetching image."
            UIView.animateWithDuration(1.0, delay: 0, options: .TransitionCrossDissolve , animations: {
                sself.prepareView.alpha = 0
                }) { complete in
                    if complete {
                        UIView.animateWithDuration(1, options: .TransitionCrossDissolve){
                            sself.opponentAvatarView.alpha = 1
                            sself.opponentDisplayNameLabel.alpha = 1
                            sself.opponentRankLabel.alpha = 1
                            sself.opponentLevelLabel.alpha = 1
                            sself.opponentBadgeImageView.alpha = 1
                        }
                        sself.timerStart()
                    }
            }
        }
        // Do any additional setup after loading the view.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func bindGame(game:Game){
        self.game = game
        self.player = game.selfUser
        self.opponent = game.awayUser
//        self.determineUserRoles(game)
    }
    
    private func determineUserRoles(game:Game) {
        if game.initiatingPlayer.userId == user.userId {
            player = game.initiatingPlayer
            opponent = game.opponentPlayer
        } else if game.opponentPlayer.userId == user.userId {
            player = game.opponentPlayer
            opponent = game.initiatingPlayer
        } else {
            println("Shouldn't happen")
        }
    }
    
    private func prepareGame(game:Game, completionHandler:()->()) {
        var qSet = game.questionSet
        var count:Int = 0
        var tcount = game.questionSet.count
        weak var wself = self
        for q in qSet {
            q.fetchImage {
                var sself = wself!
                count += 1
                sself.prepareViewDetailLabel.text = "\(count) of \(tcount)"
                if count == game.questionSet.count {
                    sself.game = game
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
    
    private func startGame(){
        
        let topView = topBoxBackgroundImageView.superview!
        let bottomView = bottomBoxBackgroundImageView.superview!
        
        var topEndFrame = topView.frame
        topEndFrame.origin.x += 500
        
        var bottomEndFrame = bottomView.frame
        bottomEndFrame.origin.x -= 500
        
        weak var wself = self
        
        UIView.animateWithDuration(1, delay: 1, options: .TransitionNone, animations: {
            var sself = wself!
            sself.countdownTimerLabel.alpha = 0
            topView.frame = topEndFrame
            bottomView.frame = bottomEndFrame
            sself.roundTimerImageView.bounds.size = CGSizeZero
            }) { complete in
                if complete {
                    var sself = wself!
                    usleep(1)
                    sself.performSegueWithIdentifier("PresentQuizSegue", sender: sself)
                }
        }
    }
    
    private func configureUI(){
        self.opponentAvatarView.alpha = 0
        self.opponentDisplayNameLabel.alpha = 0
        self.opponentRankLabel.alpha = 0
        self.opponentLevelLabel.alpha = 0
        self.opponentBadgeImageView.alpha = 0
        weak var wself = self
        NetworkClient.fetchImageFromURLString(player.pictureURL, progressHandler: nil) { image, error in
            var sself = wself!
            if let err = error {
                println(err)
            }
            sself.selfAvatarView.image = image
        }
        self.selfDisplayNameLabel.text = player.displayName
        
        NetworkClient.fetchImageFromURLString(opponent.pictureURL, progressHandler: nil) { image, error in
            var sself = wself!
            if let err = error {
                println(err)
            }
            sself.opponentAvatarView.image = image
        }
        self.opponentDisplayNameLabel.text = opponent.displayName
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "PresentQuizSegue" {
            if let app = UIApplication.sharedApplication().delegate as? AppDelegate {
                app.bgmPlayer.stop()
            }
            let vc =  segue.destinationViewController as QuizViewController
            vc.bindGameAndUsers(self.game, player: self.player, opponent: self.opponent)
        }
    }
    
    
}
