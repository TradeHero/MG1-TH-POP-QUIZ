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
    @IBOutlet weak var challengerDisplayNameLabel: UILabel!
    @IBOutlet weak var challengerWinsLabel: UILabel!
    @IBOutlet weak var selfWinsLabel: UILabel!
    @IBOutlet weak var challengerImageView: UIImageView!
    
    var challengeID: Int!

    var delegate: HomeTurnChallengesTableViewCellDelegate!
    @IBAction func acceptChallengeAction(sender: AnyObject) {
        self.delegate.homeTurnChallengesCell(self, didTapAcceptChallenge: challengeID)
    }
    
    func bindChalllenge(challenge:Game) {
        challengeID = 0
    }
}

protocol HomeTurnChallengesTableViewCellDelegate : class, NSObjectProtocol {
    func homeTurnChallengesCell(cell:HomeTurnChallengesTableViewCell, didTapAcceptChallenge challengeId:Int)
}

