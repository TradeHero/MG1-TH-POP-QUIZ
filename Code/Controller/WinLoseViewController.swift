//
//  WinLoseViewController.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/31/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class WinLoseViewController: UIViewController {

    @IBOutlet private weak var winLoseLabel: UILabel!
    
    @IBOutlet private weak var winLoseBackgroundImageView: UIImageView!
    
    @IBOutlet private weak var winLoseSmileyIcon: UIImageView!
    
    @IBOutlet private weak var winningRay: UIImageView!
    
    @IBOutlet private weak var losingRay: UIImageView!
    
    //MARK:-
    @IBOutlet private weak var largeBoxBackground: UIImageView!
    
    @IBOutlet private weak var largeBoxAvatarView: AvatarRoundedView!

    @IBOutlet private weak var largeBoxNameLabel: UILabel!
    
    @IBOutlet private weak var largeBoxRankLabel: UILabel!
    
    @IBOutlet private weak var largeBoxLevelLabel: UILabel!
    
    @IBOutlet private weak var largeBoxScoreLabel: UILabel!
    
    @IBOutlet private weak var smallBoxAvatarView: AvatarRoundedView!
    
    @IBOutlet private weak var smallBoxNameLabel: UILabel!
    
    @IBOutlet private weak var smallBoxRankLabel: UILabel!
    
    @IBOutlet private weak var smallBoxLevelLabel: UILabel!
    
    @IBOutlet private weak var smallBoxScoreLabel: UILabel!
    
    @IBOutlet private var starViews: [UIImageView]!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func animateStars(){
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
        winningRay.alpha = 0
        losingRay.alpha = 1
    }
    
    func bindResult(selfUser:THUser, opponentUser:THUser, selfScore:Int, opponentScore:Int) {
        if selfScore > opponentScore {
            configureAsWinningScene()
        } else {
            configureAsLosingScene()
        }
        largeBoxNameLabel.text = selfUser.displayName
//        largeBoxRankLabel = selfUser.rank
//        largeBoxLevelLabel.text = selfUser.level
        largeBoxScoreLabel.text = "\(selfScore)"
        smallBoxNameLabel.text = opponentUser.displayName
//        smallBoxRankLabel = opponentUser.rank
//        smallBoxLevelLabel.text = opponentUser.level
        smallBoxScoreLabel.text = "\(opponentScore)"
        NetworkClient.fetchImageFromURLString(selfUser.pictureURL, progressHandler: nil, completionHandler: {
        (image, error) in
            self.largeBoxAvatarView.image = image
        })
        
        NetworkClient.fetchImageFromURLString(opponentUser.pictureURL, progressHandler: nil, completionHandler: {
            (image, error) in
            self.smallBoxAvatarView.image = image
        })
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    
    }
    

}
