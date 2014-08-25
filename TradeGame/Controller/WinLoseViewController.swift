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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    
    }
    

}
