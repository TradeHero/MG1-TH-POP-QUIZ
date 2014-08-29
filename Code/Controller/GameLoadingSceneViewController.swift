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
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
