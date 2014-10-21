//
//  SettingsControlTableViewCell.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 9/16/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

enum SettingsControlType: Int {
    case PushNotification
    case BackgroundMusic
    case NotificationHead
    case SoundEffect
    case VibrationEffect
    
    var description: String {
        switch self {
        case .PushNotification:
            return "Push Notification"
        case .BackgroundMusic:
            return "Background Music"
        case .NotificationHead:
            return "Notification Head"
        case .SoundEffect:
            return "Sound Effect"
        case .VibrationEffect:
            return "Vibration Effect"
        }
    }
}

class SettingsControlTableViewCell: UITableViewCell {
    
    var delegate: SettingsControlTableViewCellDelegate!
    
    @IBOutlet weak var controlLogoImageView: UIImageView!
    
    @IBOutlet private weak var controlTitleLabel: UILabel!
    
    private var toggleSwitch = THSwitch.newAutoLayoutView()
    
    var type: SettingsControlType!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureSwitch()
        self.contentView.addSubview(toggleSwitch)
        
        toggleSwitch.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 5)
        toggleSwitch.autoConstrainAttribute(.Horizontal, toAttribute: .Horizontal, ofView: toggleSwitch.superview, withMultiplier: 1)
        self.toggleSwitch.autoSetDimensionsToSize(CGSizeMake(65, 25))
        toggleSwitch.addTarget(self, action: "toggleAction:", forControlEvents: .ValueChanged)
        // Initialization code
    }
    
    private func configureSwitch(){
        toggleSwitch.onImage = UIImage(named: "SwitchOnBackground")
        toggleSwitch.offImage = UIImage(named: "SwitchOffBackground")
        toggleSwitch.onLabel.text = "ON"
        toggleSwitch.onLabel.font = UIFont(name: "AvenirNext-Regular", size: 10)
        toggleSwitch.onLabel.textColor = UIColor.whiteColor()
        toggleSwitch.offLabel.text = "OFF"
        toggleSwitch.offLabel.font = UIFont(name: "AvenirNext-Regular", size: 10)
        toggleSwitch.offLabel.textColor = UIColor.whiteColor()
    }
    
    
    func configureControlType(type:SettingsControlType){
        self.type = type
        
        switch type {
        case .PushNotification:
            toggleSwitch.on = kTHPushNotificationOn
            controlLogoImageView.image = UIImage(named: "PushNotificationSettingsIcon")
        case .VibrationEffect:
            toggleSwitch.on = kTHVibrationEffectOn
            controlLogoImageView.image = UIImage(named: "VibrationSettingsIcon")
        case .NotificationHead:
            toggleSwitch.on = kTHNotificationHeadOn
            controlLogoImageView.image = UIImage(named: "VibrationSettingsIcon")
        default:
            println("Wrong type of control")
            break
        }
        
        controlTitleLabel.text = type.description
    }
    
    @IBAction func toggleAction(sender: AnyObject) {
        self.delegate.settingsControlTableViewCell(self, didToggleSwitch: toggleSwitch.on)
    }
    
    override func prepareForReuse() {
        controlTitleLabel.text = ""
    }
}

protocol SettingsControlTableViewCellDelegate :class, NSObjectProtocol {
    func settingsControlTableViewCell(cell: SettingsControlTableViewCell, didToggleSwitch on:Bool)
    func settingsSliderTableViewCell(cell: SettingsSliderTableViewCell, didSliderValueChanged value:Float)
}