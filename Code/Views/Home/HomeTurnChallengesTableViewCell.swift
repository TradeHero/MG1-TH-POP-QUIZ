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
        self.challengerImageView.layer.borderWidth = 1
        self.challengerImageView.layer.borderColor = UIColor.whiteColor().CGColor
        self.challengerImageView.clipsToBounds = true
        self.clipsToBounds = true
        self.challengerDisplayNameLabel.text = ""
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
        self.player = game.selfUser
        self.opponent = game.awayUser
        
        switch status {
        case .Nudge, .Invited:
            if game.isGameCompletedByChallenger {
                var attributedString = NSMutableAttributedString(string:"Your Score: ")
                var boldStr = NSMutableAttributedString(string:"\(game.initiatingPlayerResult.rawScore.decimalFormattedString)", attributes:[NSFontAttributeName : UIFont(name: "AvenirNext-Bold", size: 14)])
                attributedString.appendAttributedString(boldStr)
                self.scoreDetailLabel.attributedText  = attributedString
            }
        case .Play, .Accept:
            if game.isGameCompletedByChallenger {
                var attributedString = NSMutableAttributedString(string:"Score: ")
                var boldStr = NSMutableAttributedString(string:"\(game.initiatingPlayerResult.rawScore.decimalFormattedString)", attributes:[NSFontAttributeName : UIFont(name: "AvenirNext-Bold", size: 14)])
                attributedString.appendAttributedString(boldStr)

                self.scoreDetailLabel.attributedText  = attributedString
            }
        }
        
        self.challengerDisplayNameLabel.text = opponent!.displayName
        self.challengerImageView.sd_setImageWithURL(NSURL(string: opponent!.pictureURL)) { (image, _, _, _) in
            self.challengerImageView.image = image.centerCropImage()
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
        self.gameStatusImageView.image = UIImage(named: "NewChallengeLabelBox")
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
        self.actionButton.setTitle("Waiting..", forState: .Normal)
        self.actionButton.setBackgroundImage(UIImage(named: "BlueButtonBackground"), forState: .Normal)
        self.gameStatusImageView.alpha = 0
        self.gameStatusImageView.image = nil
    }
    
    override func prepareForReuse() {
        self.challengerImageView.sd_cancelCurrentImageLoad()
        self.challengerImageView.image = nil
        self.challengerDisplayNameLabel.text = ""
        self.scoreDetailLabel.text = ""
        super.layoutIfNeeded()
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
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
    }
    
}

protocol HomeTurnChallengesTableViewCellDelegate : class, NSObjectProtocol {
    func homeTurnChallengesCell(cell:HomeTurnChallengesTableViewCell, didTapAcceptChallenge game:Game)
}

