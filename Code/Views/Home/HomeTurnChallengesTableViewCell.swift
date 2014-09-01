//
//  HomeTurnChallengesTableViewCell.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/22/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class HomeTurnChallengesTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var challengerDisplayNameLabel: UILabel!
    @IBOutlet weak var challengerWinsLabel: UILabel!
    @IBOutlet weak var selfWinsLabel: UILabel!
    @IBOutlet weak var challengerImageView: UIImageView!
    
    var game: Game!
    

    var delegate: HomeTurnChallengesTableViewCellDelegate!
    @IBAction func acceptChallengeAction(sender: AnyObject) {
        self.delegate.homeTurnChallengesCell(self, didTapAcceptChallenge: self.game.gameID)
    }
    
    func bindChalllenge(challenge:Game) {
        self.game = challenge
        self.challengerDisplayNameLabel.text = game.opponentPlayer.displayName
        self.challengerWinsLabel.text = String(0)
        self.challengerImageView.sd_setImageWithURL(NSURL(string: game.opponentPlayer.pictureURL))
    }
    
    
    func configureAsTakenChallengesMode() {
        self.actionButton.hidden = true
    }
    
    func configureAsPlayChallengesMode() {
        self.actionButton.hidden = false
        self.actionButton.setTitle("Play", forState: .Normal)
        self.actionButton.setBackgroundImage(UIImage(named: "GreenButtonBackground"), forState: .Normal)
    }
    
    func configureAsAcceptChallengeMode() {
        self.actionButton.hidden = false
        self.actionButton.setTitle("Accept", forState: .Normal)
        self.actionButton.setBackgroundImage(UIImage(named: "RedButtonBackground"), forState: .Normal)
    }
    
    override func prepareForReuse() {
        self.challengerImageView.image = nil
        self.challengerDisplayNameLabel.text = ""
        self.challengerWinsLabel.text = ""
    }
}

protocol HomeTurnChallengesTableViewCellDelegate : class, NSObjectProtocol {
    func homeTurnChallengesCell(cell:HomeTurnChallengesTableViewCell, didTapAcceptChallenge challengeId:Int)
}

