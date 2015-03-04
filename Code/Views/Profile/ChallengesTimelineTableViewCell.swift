//
//  ChallengesTimelineTableViewCell.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 9/12/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import SDWebImage

class ChallengesTimelineTableViewCell: UITableViewCell {

    @IBOutlet weak var upperVerticalBar: UIView!
    @IBOutlet weak var lowerVerticalBar: UIView!
    @IBOutlet private weak var circularView: DesignableRoundedView!
    @IBOutlet private weak var winLoseVSLabel: UILabel!
    @IBOutlet private weak var opponentImageView: UIImageView!
    @IBOutlet private weak var opponentDisplayNameLabel: UILabel!
    @IBOutlet private weak var scoreVersusLabel: UILabel!

    private var winningColor = UIColor(hex: 0x7ED321)
    private var losingColor = UIColor(hex: 0xD0021B)

    private var game: Game!

    private var opponent: THUser!

    private var playerResult: GameResult!
    private var opponentResult: GameResult!

    func bindGame(game: Game) {
        if game.isGameCompletedByBothPlayer {
            self.game = game
            self.opponent = game.awayUser

            if game.opponentPlayer === game.awayUser {
                self.opponentResult = game.opponentPlayerResult
                self.playerResult = game.initiatingPlayerResult
            } else {
                self.opponentResult = game.initiatingPlayerResult
                self.playerResult = game.opponentPlayerResult
            }

            setScoreVersusLabelAttrString()
            setWinLoseLabelAttrString()
            setDotColor()

            opponentImageView.sd_setImageWithURL(NSURL(string: opponent!.pictureURL)) {
                [unowned self] (image, _, _, _) in
                self.opponentImageView.image = image.centerCropImage()
            }
            opponentDisplayNameLabel.text = opponent.displayName
        } else {
            debugPrintln("game incomplete")
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    private func setScoreVersusLabelAttrString() {
        var color = playerResult.finalScore > opponentResult.finalScore ? winningColor : losingColor
        var attributedString = NSMutableAttributedString(string: playerResult.finalScore.decimalFormattedString, attributes: [NSFontAttributeName: UIFont(name: "AvenirNext-Bold", size: 15)!, NSForegroundColorAttributeName: color])
        attributedString.appendAttributedString(NSAttributedString(string: " vs ", attributes: [NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 15)!, NSForegroundColorAttributeName: UIColor.blackColor()]))
        attributedString.appendAttributedString(NSAttributedString(string: opponentResult.finalScore.decimalFormattedString, attributes: [NSFontAttributeName: UIFont(name: "AvenirNext-Bold", size: 15)!, NSForegroundColorAttributeName: UIColor.blackColor()]))
        scoreVersusLabel.attributedText = attributedString
    }

    private func setWinLoseLabelAttrString() {
        var color = playerResult.finalScore > opponentResult.finalScore ? winningColor : losingColor
        var str = playerResult.finalScore > opponentResult.finalScore ? "WIN" : "LOSE"

        var attributedString = NSMutableAttributedString(string: str, attributes: [NSFontAttributeName: UIFont(name: "AvenirNext-Bold", size: 15)!, NSForegroundColorAttributeName: color])
        attributedString.appendAttributedString(NSAttributedString(string: " vs", attributes: [NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 15)!, NSForegroundColorAttributeName: UIColor.blackColor()]))
        winLoseVSLabel.attributedText = attributedString
    }

    private func setDotColor() {
        self.circularView.backgroundColor = playerResult.finalScore > opponentResult.finalScore ? winningColor : losingColor
    }

    override func prepareForReuse() {
        opponentDisplayNameLabel.text = ""
        scoreVersusLabel.text = ""
        opponentImageView.image = nil
        opponentImageView.sd_cancelCurrentImageLoad()
        upperVerticalBar.hidden = false
        lowerVerticalBar.hidden = false
    }
}
