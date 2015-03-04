//
//  FriendsChallengeCellTableViewCell.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 8/13/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

extension UIButton {
    func setupAsInviteButton() {
        self.setBackgroundImage(UIImage(named: "RedButtonBackground"), forState: .Normal)
        self.setTitle("Invite", forState: .Normal)
        self.enable()
        self.alpha = 1
    }

    func setupAsChallengeButton() {
        self.setBackgroundImage(UIImage(named: "GreenButtonBackground"), forState: .Normal)
        self.setTitle("Challenge", forState: .Normal)
        self.enable()
        self.alpha = 1
    }

    func setupAsInvitedButton() {
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
            if self.friendUser != nil {
                if self.friendUser.isTHUser {
                    inviteOrChallengeButton.setupAsChallengeButton()
                } else {
                    if self.friendUser.alreadyInvited {
                        inviteOrChallengeButton.setupAsInvitedButton()
                    } else {
                        inviteOrChallengeButton.setupAsInviteButton()
                    }
                }
            }
        }
    }

    var invitableFriend: FacebookInvitableFriend!


    var delegate: FriendsChallengeCellTableViewCellDelegate!

    lazy var index: Int = Int()

    @IBOutlet weak var inviteOrChallengeButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.friendAvatarView.layer.borderWidth = 1
        self.friendAvatarView.layer.borderColor = UIColor.whiteColor().CGColor
        self.friendAvatarView.clipsToBounds = true
    }

    @IBAction func challengeOrInviteAction(sender: AnyObject) {
        if (self.invitableFriend != nil) {
            self.delegate.friendUserCell(self, didTapInviteUser: self.invitableFriend)
        } else if self.friendUser.isTHUser {
            self.delegate.friendUserCell(self, didTapChallengeUser: self.friendUser.userID)
        }

    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.invitableFriend = nil
        self.friendUser = nil
        self.friendAvatarView.sd_cancelCurrentImageLoad()
        self.friendAvatarView.image = nil
        self.friendNameLabel.text = nil
        super.layoutIfNeeded()
    }

    func bindFriendUser(friendUser: THUserFriend, index: Int) {
        self.friendUser = friendUser
        self.friendNameLabel.text = friendUser.name
        self.friendAvatarView.sd_setImageWithURL(NSURL(string: friendUser.facebookPictureURL)) {
            [unowned self] (image, _, _, _) in
            self.friendAvatarView.image = image.centerCropImage()
        }
        self.index = index
    }

    func bindInvitableFriend(invitableFriend: FacebookInvitableFriend, index: Int) {
        self.invitableFriend = invitableFriend
        self.friendNameLabel.text = invitableFriend.name
        self.friendAvatarView.sd_setImageWithURL(NSURL(string: invitableFriend.pictureUrl!)) {
            [unowned self] (image, _, _, _) in
            self.friendAvatarView.image = image.centerCropImage()
        }
        self.index = index
        inviteOrChallengeButton.setupAsInviteButton()

    }

    override var frame: CGRect {
        get {
            return super.frame
        }

        set(fr) {
            var frame = fr
            frame.origin.y += 3
            frame.size.height -= 5;
            super.frame = frame
            UIView.roundView(self, onCorner: .AllCorners, radius: 5)
        }
    }


}

protocol FriendsChallengeCellTableViewCellDelegate: class, NSObjectProtocol {
    func friendUserCell(cell: FriendsChallengeCellTableViewCell, didTapChallengeUser userID: Int)

    func friendUserCell(cell: FriendsChallengeCellTableViewCell, didTapInviteUser inviteUser: FacebookInvitableFriend)
}
