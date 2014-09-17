//
//  GameResultDetailTableViewCell.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 9/8/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class GameResultDetailTableViewCell: UITableViewCell {

    @IBOutlet private weak var attributeTitleLabel: UILabel!
    @IBOutlet private weak var selfAttributedDetailLabel: UILabel!
    @IBOutlet private weak var opponentAttributedDetailLabel: UILabel!
    
    var attribute: String = "" {
        didSet {
            self.attributeTitleLabel.text = attribute
        }
    }
    
    var selfAttributeDetail: String = "" {
        didSet {
            self.selfAttributedDetailLabel.text = selfAttributeDetail
        }
    }
    
    var opponentAttributeDetail: String = "" {
        didSet {
            self.opponentAttributedDetailLabel.text = opponentAttributeDetail
        }
    }
    
    var labelTintColor: UIColor = UIColor.blackColor() {
        didSet {
            self.attributeTitleLabel.textColor = labelTintColor
            self.selfAttributedDetailLabel.textColor = labelTintColor
            self.opponentAttributedDetailLabel.textColor = labelTintColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.layer.cornerRadius = 3
//        self.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
