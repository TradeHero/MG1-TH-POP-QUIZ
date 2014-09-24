//
//  SettingSliderTableViewCell.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 9/16/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class SettingsSliderTableViewCell: UITableViewCell {

    @IBOutlet weak var controlLogoImageView: UIImageView!
    
    @IBOutlet weak var controlTitle: UILabel!
    
    @IBOutlet weak var controlSlider: JMMarkSlider!
    
    var type: SettingsControlType!
    
    var delegate: SettingsControlTableViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureSlider()
        // Initialization code
    }
    
    func configureControlType(type:SettingsControlType) {
        self.type = type
        switch type {
        case .BackgroundMusic:
            controlSlider.value = kTHBackgroundMusicValue
            controlLogoImageView.image = UIImage(named: "MusicSettingsIcon")
        case .SoundEffect:
            controlSlider.value = kTHSoundEffectValue
            controlLogoImageView.image = UIImage(named: "SoundEffectSettingsIcon")
        default:
            break
        }
        controlTitle.text = type.description
    }

    private func configureSlider(){
        controlSlider.selectedBarColor = UIColor(hex: 0xFAD961)
        controlSlider.unselectedBarColor = UIColor.whiteColor()
        controlSlider.handlerImage = UIImage.imageWithImage(UIImage(named: "SliderHandlerControlBackground"), newSize: CGSizeMake(30, 30))
        controlSlider.markPositions = nil
    }

    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func sliderAction(sender: AnyObject) {
        self.delegate.settingsSliderTableViewCell(self, didSliderValueChanged: controlSlider.value)
    }
    
    override func prepareForReuse() {
        controlTitle.text = ""
        controlLogoImageView.image = nil
    }
}
