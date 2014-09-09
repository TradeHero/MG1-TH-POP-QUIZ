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
    case Accept
    case Nudge
    case Invited
}

class HomeTurnChallengesTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 3
        self.clipsToBounds = true
        // Initialization code
    }
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var challengerDisplayNameLabel: UILabel!
    @IBOutlet weak var challengerImageView: UIImageView!
    @IBOutlet weak var scoreDetailLabel: UILabel!
    @IBOutlet weak var gameStatusImageView: UIImageView!
    
    var game: Game!
    
    var status: ChallengeStatus = .Play {
        didSet {
            switch status {
            case .Play:
                configureAsPlayChallengesMode()
            case .Nudge:
                configureAsNudgeMode()
            case .Invited:
                configureAsInvitedMode()
            case .Accept:
                configureAsAcceptChallengeMode()
            }
        }
    }
    
    var player: THUser!
    var opponent: THUser!
    
    var delegate: HomeTurnChallengesTableViewCellDelegate!
    @IBAction func acceptChallengeAction(sender: AnyObject) {
        self.delegate.homeTurnChallengesCell(self, didTapAcceptChallenge: self.game)
    }
    
    func bindChalllenge(challenge:Game, status:ChallengeStatus) {
        self.game = challenge
        self.status = status
        
        switch status {
        case .Nudge, .Invited:
            player = game.opponentPlayer
            opponent = game.initiatingPlayer
        case .Play, .Accept:
            player = game.initiatingPlayer
            opponent = game.opponentPlayer
        }
        
        self.challengerDisplayNameLabel.text = player!.displayName
        self.challengerImageView.sd_setImageWithURL(NSURL(string: player!.pictureURL))
        
        let str = self.challengerDisplayNameLabel.text as NSString?
        let r = str?.sizeWithAttributes([NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 14.0)]).width
        
        self.challengerDisplayNameLabel.width = r!
        self.gameStatusImageView.x = self.challengerDisplayNameLabel.bounds.origin.x + r! + 5

        if let result = self.game.initiatingPlayerResult {
            self.scoreDetailLabel.text = "\(player.displayName)'s Score: \(result.rawScore)"
        } else {
            self.scoreDetailLabel.text = ""
        }
        
    }
    
    func configureAsPlayChallengesMode() {
        self.actionButton.enabled = true
        self.actionButton.setTitle("Play", forState: .Normal)
        self.actionButton.setBackgroundImage(UIImage(named: "GreenButtonBackground"), forState: .Normal)
        self.gameStatusImageView.alpha = 1
        self.gameStatusImageView.image = UIImage(named: "BeatMeLabelBox")
        
    }
    
    func configureAsAcceptChallengeMode() {
        self.actionButton.enabled = true
        self.actionButton.setTitle("Accept", forState: .Normal)
        self.actionButton.setBackgroundImage(UIImage(named: "RedButtonBackground"), forState: .Normal)
        self.gameStatusImageView.alpha = 1
        self.gameStatusImageView.image = UIImage(named: "BeatMeLabelBox")
    }
    
    func configureAsNudgeMode(){
        self.actionButton.enabled = true
        self.actionButton.setTitle("Nudge", forState: .Normal)
        self.actionButton.setBackgroundImage(UIImage(named: "BlueButtonBackground"), forState: .Normal)
        self.gameStatusImageView.alpha = 0
        self.gameStatusImageView.image = nil
    }
    
    func configureAsInvitedMode() {
        
        self.actionButton.enabled = false
        self.actionButton.setTitle("Invited", forState: .Normal)
        self.actionButton.setBackgroundImage(UIImage(named: "BlueButtonBackground"), forState: .Normal)
        self.gameStatusImageView.alpha = 0
        self.gameStatusImageView.image = nil
    }
    
    override func prepareForReuse() {
        self.challengerImageView.image = nil
        self.challengerDisplayNameLabel.text = ""
        self.scoreDetailLabel.text = ""
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        
        set(fr) {
            var frame = fr
            frame.origin.y += 3
            frame.size.height -=  5;
            super.frame = frame
        }
    }
    
}

protocol HomeTurnChallengesTableViewCellDelegate : class, NSObjectProtocol {
    func homeTurnChallengesCell(cell:HomeTurnChallengesTableViewCell, didTapAcceptChallenge game:Game)
}

