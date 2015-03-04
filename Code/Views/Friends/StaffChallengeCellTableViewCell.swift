//
//  StaffChallengeCellTableViewCell.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 13/10/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class StaffChallengeCellTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarView: AvatarHexagonalView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    private var staffUser: StaffUser!

    var delegate: StaffChallengeCellTableViewCellDelegate!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    @IBAction func challengeAction(sender: AnyObject) {
        self.delegate.staffChallengeCellTableViewCell(self, didTapChallengeWithStaffUser: self.staffUser.userId)
    }

    func bindStaffUser(staffUser: StaffUser) {
        self.staffUser = staffUser
        self.nameLabel.text = staffUser.displayName
        self.titleLabel.text = staffUser.funnyName
        self.avatarView.image = UIImage(named: "EmptyAvatar")
        NetworkClient.fetchImageFromURLString(staffUser.pictureURL, progressHandler: nil) {
            [unowned self] (image, error) -> () in
            if let img = image {
                self.avatarView.image = image.centerCropImage()
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.avatarView.image = nil
        self.nameLabel.text = nil
        self.titleLabel.text = nil
        super.layoutIfNeeded()
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

protocol StaffChallengeCellTableViewCellDelegate: class, NSObjectProtocol {
    func staffChallengeCellTableViewCell(cell: StaffChallengeCellTableViewCell, didTapChallengeWithStaffUser userId: Int)
}
