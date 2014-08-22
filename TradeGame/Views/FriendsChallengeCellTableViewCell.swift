//
//  FriendsChallengeCellTableViewCell.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/13/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

private extension UIButton {
    func setupAsInviteButton(){
        self.setBackgroundImage(UIImage(named: "RedButtonBackground"), forState: .Normal)
        self.setTitle("Invite", forState: .Normal)
        self.enable()
        self.alpha = 1
    }
    
    func setupAsChallengeButton(){
        self.setBackgroundImage(UIImage(named: "GreenButtonBackground"), forState: .Normal)
        self.setTitle("Challenge", forState: .Normal)
        self.enable()
        self.alpha = 1
    }

    func setupAsInvitedButton(){
        self.setBackgroundImage(UIImage(named: "RedButtonBackground"), forState: .Normal)
        self.setTitle("Invited", forState: .Normal)
        self.disable()
        self.alpha = 0.5
    }
}
class FriendsChallengeCellTableViewCell: UITableViewCell {

    @IBOutlet weak var friendAvatarView: UIImageView!
    @IBOutlet weak var friendNameLabel: UILabel!
    
    var friendUser: THUserFriend! {
        didSet {
            if self.friendUser.isTHUser {
                inviteOrChallengeButton.setupAsChallengeButton()
            } else {
                if self.friendUser.alreadyInvited {
                    inviteOrChallengeButton.setupAsInvitedButton()
                }else{
                    inviteOrChallengeButton.setupAsInviteButton()
                }
            }
        }
    }
    var delegate: FriendsChallengeCellTableViewCellDelegate!
    
    @IBOutlet weak var inviteOrChallengeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.friendAvatarView.layer.borderWidth = 2
        self.friendAvatarView.layer.borderColor = UIColor.whiteColor().CGColor
        self.friendAvatarView.clipsToBounds = true
        self.layer.cornerRadius = 3
        self.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    @IBAction func challengeOrInviteAction(sender: AnyObject) {
        if self.friendUser.isTHUser {
            self.delegate.friendUserCell(self, didTapChallengeUser: self.friendUser.userID)
        } else {
            self.delegate.friendUserCell(self, didTapInviteUser: self.friendUser.facebookID)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.friendAvatarView.sd_cancelCurrentImageLoad()
        self.friendAvatarView.image = nil
        self.friendNameLabel.text = nil
    }
    
    func bindFriendUser(friendUser:THUserFriend){
        self.friendUser = friendUser
        self.friendNameLabel.text = friendUser.name
        self.friendAvatarView.sd_setImageWithURL(NSURL(string: friendUser.facebookPictureURL))
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

protocol FriendsChallengeCellTableViewCellDelegate : class, NSObjectProtocol {
    func friendUserCell(cell:FriendsChallengeCellTableViewCell, didTapChallengeUser userID:Int)
    func friendUserCell(cell:FriendsChallengeCellTableViewCell, didTapInviteUser facebookID:Int)
}
