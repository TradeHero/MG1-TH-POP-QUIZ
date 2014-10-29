//
//  MusicPlayer.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 29/10/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import AVFoundation

var musicPlayer: AVAudioPlayer!

var isSoundEffectOn: Bool {
get{
    return musicPlayer.playing
}
}

func prepareForMusicPlayer(soundName:String) {
    musicPlayer = AVAudioPlayer.createAudioPlayer(soundName, extensionName: "mp3")
    musicPlayer.numberOfLoops = -1
    musicPlayer.volume = kTHBackgroundMusicValue
}

