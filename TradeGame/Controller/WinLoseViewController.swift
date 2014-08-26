//
//  WinLoseViewController.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/31/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class WinLoseViewController: UIViewController {

    @IBOutlet weak var winLoseLabel: UILabel!
    
    @IBOutlet weak var winLoseBackgroundImageView: UIImageView!
    
    @IBOutlet weak var winLoseSmileyIcon: UIImageView!
    
    @IBOutlet weak var winningRay: UIImageView!
    
    @IBOutlet weak var losingRay: UIImageView!
    
    //MARK:-
    @IBOutlet weak var largeBoxBackground: UIImageView!
    
    @IBOutlet weak var largeBoxAvatarView: AvatarRoundedView!

    @IBOutlet weak var largeBoxNameLabel: UILabel!
    
    @IBOutlet weak var largeBoxRankLabel: UILabel!
    
    @IBOutlet weak var largeBoxLevelLabel: UILabel!
    
    @IBOutlet weak var largeBoxScoreLabel: UILabel!
    
    @IBOutlet weak var smallBoxAvatarView: AvatarRoundedView!
    
    @IBOutlet weak var smallBoxNameLabel: UILabel!
    
    @IBOutlet weak var smallBoxRankLabel: UILabel!
    
    @IBOutlet weak var smallBoxLevelLabel: UILabel!
    @IBOutlet weak var smallBoxScoreLabel: UILabel!
    
    @IBOutlet var starViews: [UIImageView]!
    
    
    
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
    
    func configureAsWinningScene() {
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
    
    func configureAsLosingScene() {
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
