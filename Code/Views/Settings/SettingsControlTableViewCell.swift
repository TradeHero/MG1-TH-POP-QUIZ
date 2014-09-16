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
    case SoundEffect
    case VibrationEffect
    
    var description: String {
        switch self {
        case .PushNotification:
            return "Push Notification"
        case .BackgroundMusic:
            return "Background Music"
        case .SoundEffect:
            return "Sound Effect"
        case .VibrationEffect:
            return "Vibration Effect"
        }
    }
}

class SettingsControlTableViewCell: UITableViewCell {

    @IBOutlet private weak var controlSlider: UISlider!
    var delegate: SettingsControlTableViewCellDelegate!
    
    @IBOutlet private weak var controlTitleLabel: UILabel!
    
    private var toggleSwitch = THSwitch(frame: CGRectMake(214, 5, 65, 25))
    
    var type: SettingsControlType!
    override func awakeFromNib() {
        super.awakeFromNib()
        configureSwitch()
        self.contentView.addSubview(toggleSwitch)
        toggleSwitch.addTarget(self, action: "toggleAction:", forControlEvents: .ValueChanged)
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
            toggleSwitch.hidden = false
            controlSlider.hidden = true
            toggleSwitch.on = kTHPushNotificationOn
            break
        case .BackgroundMusic:
            toggleSwitch.hidden = true
            controlSlider.hidden = false
            controlSlider.value = kTHBackgroundMusicValue
            break
        case .SoundEffect:
            toggleSwitch.hidden = true
            controlSlider.hidden = false
            controlSlider.value = kTHSoundEffectValue
            break
        case .VibrationEffect:
            toggleSwitch.hidden = false
            controlSlider.hidden = true
            toggleSwitch.on = kTHVibrationEffectOn
            break
        }
        controlTitleLabel.text = type.description
    }
    
    @IBAction func toggleAction(sender: AnyObject) {
        self.delegate.settingsControlTableViewCell(self, didToggleSwitch: toggleSwitch.on)
    }
    
    @IBAction func sliderAction(sender: AnyObject) {
        self.delegate.settingsControlTableViewCell(self, didSliderValueChanged: Float(controlSlider.value))
    }
    
    override func prepareForReuse() {
        controlTitleLabel.text = ""
        controlSlider.hidden = false
        toggleSwitch.hidden = false
    }
}

protocol SettingsControlTableViewCellDelegate :class, NSObjectProtocol {
    func settingsControlTableViewCell(cell: SettingsControlTableViewCell, didToggleSwitch on:Bool)
    func settingsControlTableViewCell(cell: SettingsControlTableViewCell, didSliderValueChanged value:Float)
}