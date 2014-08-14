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
    
    var friendUserID: Int!
    var delegate: FriendsChallengeCellTableViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    @IBAction func challengeAction(sender: AnyObject) {
        if self.friendUserID != nil {
            self.delegate.friendUserCell(self, didTapChallengeUser: self.friendUserID)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.friendAvatarView.image = nil
        self.friendNameLabel.text = nil
    }
    
    func bindFriendUser(friendUser:THUserFriend){
        self.friendNameLabel.text = friendUser.name ?? "Unknown user"
        NetworkClient.fetchImageFromURLString(friendUser.facebookPictureURL, progressHandler: nil, completionHandler: {
            image,error in
            self.friendAvatarView.image = image
        })
        self.friendUserID = friendUser.userID
    }
}

protocol FriendsChallengeCellTableViewCellDelegate : class, NSObjectProtocol {
    func friendUserCell(cell:FriendsChallengeCellTableViewCell, didTapChallengeUser userID:Int)
}
