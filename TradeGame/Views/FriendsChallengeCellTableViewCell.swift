//
//  FriendsChallengeCellTableViewCell.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/13/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class FriendsChallengeCellTableViewCell: UITableViewCell {

    @IBOutlet weak var friendAvatarView: AvatarRoundedView!
    @IBOutlet weak var friendNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBOutlet weak var challengeAction: DesignableButton!
    
}
