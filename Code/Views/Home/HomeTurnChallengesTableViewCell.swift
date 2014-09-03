//
//  HomeTurnChallengesTableViewCell.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/22/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
enum ChallengeStatus: Int {
    case Play
    case Done
    case Accept
}

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
    
    var status: ChallengeStatus = .Play {
        didSet {
            switch status {
            case .Play:
                configureAsPlayChallengesMode()
            case .Done:
                configureAsTakenChallengesMode()
            case .Accept:
                configureAsAcceptChallengeMode()
            }
        }
    }
    
    var player: THUser!
    var opponent: THUser!
    
    var delegate: HomeTurnChallengesTableViewCellDelegate!
    @IBAction func acceptChallengeAction(sender: AnyObject) {
        self.delegate.homeTurnChallengesCell(self, didTapAcceptChallenge: self.game.gameID)
    }
    
    func bindChalllenge(challenge:Game, status:ChallengeStatus) {
        self.game = challenge
        self.status = status
        
        switch status {
        case .Done:
            player = game.opponentPlayer
            opponent = game.initiatingPlayer
        default:
            player = game.initiatingPlayer
            opponent = game.opponentPlayer
        }
        
        self.challengerDisplayNameLabel.text = player!.displayName
        self.challengerWinsLabel.text = String(0)
        self.challengerImageView.sd_setImageWithURL(NSURL(string: player!.pictureURL))
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

