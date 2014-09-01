//
//  GameLoadingSceneViewController.swift
//  TH PopQuiz
//
//  Created by Ryne Cheow on 8/29/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class GameLoadingSceneViewController: UIViewController {
    
    @IBOutlet weak var countdownTimerLabel: UILabel!
    @IBOutlet weak var prepareView: UIView!
    @IBOutlet weak var prepareViewLabel: UILabel!
    @IBOutlet weak var prepareViewDetailLabel: UILabel!
    // top view
    
    @IBOutlet weak var topBoxBackgroundImageView: UIImageView!
    @IBOutlet weak var categoryIconImageView: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    
    @IBOutlet weak var selfAvatarView: AvatarRoundedView!
    @IBOutlet weak var selfDisplayNameLabel: UILabel!
    @IBOutlet weak var selfRankLabel: UILabel!
    @IBOutlet weak var selfLevelLabel: UILabel!
    @IBOutlet weak var selfBadgeImageView: UIImageView!
    
    // bottom view
    
    @IBOutlet weak var bottomBoxBackgroundImageView: UIImageView!
    @IBOutlet weak var opponentAvatarView: AvatarRoundedView!
    @IBOutlet weak var opponentDisplayNameLabel: UILabel!
    @IBOutlet weak var opponentRankLabel: UILabel!
    @IBOutlet weak var opponentLevelLabel: UILabel!
    @IBOutlet weak var opponentBadgeImageView: UIImageView!
    
    var user = NetworkClient.sharedClient.authenticatedUser
    var game: Game!
    
    var player: THUser!
    var opponent: THUser!
    var timer: NSTimer!
    var startTime: NSDate!
    
    var time = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController.navigationBarHidden = true
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
    
    func prepareGame(game:Game, completionHandler:()->()) {
        var qSet = game.questionSet
        var count:Int = 0
        weak var wself = self
        for q in qSet {
            q.fetchImage() {
                var sself = wself!
                count += 1
                sself.prepareViewDetailLabel.text = "\(count)/\(game.questionSet.count)"
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
        countdownTimerLabel.text = String(time--)
        println(time)
        if time == 0 {
            timer.invalidate()
            timer = nil
            startGame(1)
        }
    }
    
    func bindGame(game:Game){
        self.game = game
        self.determineUserRoles(game)
    }
    
    private func startGame(delay: dispatch_time_t){
        
        let vc = UIStoryboard.quizStoryboard().instantiateViewControllerWithIdentifier("QuizViewController") as QuizViewController
        vc.bindGameAndUsers(self.game, player: self.player, opponent: self.opponent)
        //        self.navigationController.popViewControllerAnimated(false)
        self.presentViewController(vc, animated: true, completion: nil)
        
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
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
