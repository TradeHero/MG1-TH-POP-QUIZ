//
//  NotificationTableViewCell.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 7/10/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet private weak var notificationTitleLabel: UILabel!

    @IBOutlet private weak var notificationDetailsLabel: UILabel!

    @IBOutlet private weak var notificationSubjectUserAvatarImageView: UIImageView!

    @IBOutlet private weak var gameStatusImageView: UIImageView!

    @IBOutlet private weak var notificationActionButton: UIButton!

    var delegate: NotificationTableViewCellDelegate!

    var notification: GameNotification!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func actionButton(sender: AnyObject) {
        if let d = self.delegate {
            if let notification = self.notification {
                d.notificationTableViewCell(self, didTapActionButton: notification)
            } else {
                debugPrintln("Notification object is nil")
            }
        } else {
            debugPrintln("NotificationTableViewCellDelegate not assigned.")
        }
    }

    private func configureAsNewChallengeNotification() {
        self.notificationActionButton.setBackgroundImage(UIImage(named: "RedButtonBackground"), forState: .Normal)
        self.notificationActionButton.setTitle("Accept", forState: .Normal)
        self.gameStatusImageView.hidden = false
        self.gameStatusImageView.image = UIImage(named: "NewChallengeLabelBox")
    }

    private func configureAsNudgedChallengeNotification() {
        self.notificationActionButton.setBackgroundImage(UIImage(named: "GreenButtonBackground"), forState: .Normal)
        self.notificationActionButton.setTitle("Play", forState: .Normal)
        self.gameStatusImageView.hidden = false
        self.gameStatusImageView.image = UIImage(named: "BeatMeLabelBox")
    }

    private func configureAsFinishedChallengeNotification() {
        self.notificationActionButton.setBackgroundImage(UIImage(named: "BlueButtonBackground"), forState: .Normal)
        self.notificationActionButton.setTitle("Go", forState: .Normal)
        self.gameStatusImageView.hidden = true
        self.gameStatusImageView.image = nil
    }

    func bindNotification(notification: GameNotification) {
        self.notification = notification
        self.contentView.backgroundColor = notification.read ? UIColor(hex: 0xFCE2AF) : UIColor(hex: 0xFFF1D5)

        switch notification.type {
        case .New:
            configureAsNewChallengeNotification()
        case .Nudged:
            configureAsNudgedChallengeNotification()
        case .Completed:
            configureAsFinishedChallengeNotification()
        }

        self.notificationTitleLabel.text = notification.title

        self.notificationDetailsLabel.text = notification.details

        self.notificationSubjectUserAvatarImageView.sd_setImageWithURL(NSURL(string: notification.userAvatarURLString)) {
            (image, _, _, _) in
            self.notificationSubjectUserAvatarImageView.image = image.centerCropImage()
        }

    }

}

protocol NotificationTableViewCellDelegate: class, NSObjectProtocol {
    func notificationTableViewCell(cell: NotificationTableViewCell, didTapActionButton notification: GameNotification)
}
