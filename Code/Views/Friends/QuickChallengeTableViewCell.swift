//
//  QuickChallengeTableViewCell.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 9/2/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class QuickChallengeTableViewCell: UITableViewCell {
    
    var delegate: QuickChallengeTableViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func quickChallengeAction(sender: AnyObject) {
        self.delegate.didTapQuickChallengeCellButton(self)
    }
    
}

protocol QuickChallengeTableViewCellDelegate : class, NSObjectProtocol{
    func didTapQuickChallengeCellButton(cell:QuickChallengeTableViewCell)
}