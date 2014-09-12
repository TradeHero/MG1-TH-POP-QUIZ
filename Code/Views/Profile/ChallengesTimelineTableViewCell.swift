//
//  ChallengesTimelineTableViewCell.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 9/12/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class ChallengesTimelineTableViewCell: UITableViewCell {

    @IBOutlet weak var circularView: DesignableRoundedView!
    @IBOutlet weak var winLoseVSLabel: UILabel!
    @IBOutlet weak var opponentImageView: UIImageView!
    @IBOutlet weak var opponentDisplayNameLabel: UILabel!
    @IBOutlet weak var scoreVersusLabel: UILabel!
    
    private var winningColor = UIColor(hex: 0x7ED321)
    private var losingColor = UIColor(hex: 0xD0021B)
    
    private var game: Game!
    
    private var player: THUser!
    private var opponent: THUser!
    
    private var playerResult: GameResult!
    private var opponentResult: GameResult!
    
    func bindGame(game: Game) {
        self.game = game
        
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    private func setScoreVersusLabelAttrString() {
        var color = playerResult.finalScore > opponentResult.finalScore ? winningColor : losingColor
        var attributedString = NSMutableAttributedString(string: playerResult.finalScore.decimalFormattedString, attributes: [NSFontAttributeName : UIFont(name: "AvenirNext-Bold", size: 15), NSForegroundColorAttributeName: color])
        attributedString.appendAttributedString(NSAttributedString(string: " vs ", attributes: [NSFontAttributeName : UIFont(name: "AvenirNext-Medium", size: 15), NSForegroundColorAttributeName: UIColor.blackColor()]))
        attributedString.appendAttributedString(NSAttributedString(string: opponentResult.finalScore.decimalFormattedString, attributes: [NSFontAttributeName : UIFont(name: "AvenirNext-Bold", size: 15), NSForegroundColorAttributeName: UIColor.blackColor()]))
        scoreVersusLabel.attributedText = attributedString
    }
    
    private func setWinLoseLabelAttrString() {
        var color = playerResult.finalScore > opponentResult.finalScore ? winningColor : losingColor
        var attributedString = NSMutableAttributedString(string: playerResult.finalScore.decimalFormattedString, attributes: [NSFontAttributeName : UIFont(name: "AvenirNext-Bold", size: 15), NSForegroundColorAttributeName: color])
        attributedString.appendAttributedString(NSAttributedString(string: " vs", attributes: [NSFontAttributeName : UIFont(name: "AvenirNext-Medium", size: 15), NSForegroundColorAttributeName: UIColor.blackColor()]))
        scoreVersusLabel.attributedText = attributedString
    }
}
