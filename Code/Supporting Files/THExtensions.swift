//
//  THExtensions.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 9/18/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import AVFoundation

enum THSoundEffect {
    case CorrectSound
    case WrongSound
}

extension AVAudioPlayer {
    func playSoundEffect(effect:THSoundEffect) {
        var player: AVAudioPlayer!
        switch effect {
        case .CorrectSound:
            player = AVAudioPlayer.createAudioPlayer("CorrectSound", extensionName: "caf")
            break
        case .WrongSound:
            player = AVAudioPlayer.createAudioPlayer("WrongSound", extensionName: "caf")
            break
        }
        
        if let p = player {
            p.volume = kTHSoundEffectValue
            p.numberOfLoops = 1
            p.play()
        }
    }
}