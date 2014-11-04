//
//  MusicPlayer.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 29/10/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import AVFoundation

var musicPlayer: AVAudioPlayer!

func prepareForMusicPlayer(soundURL:NSURL) {
    musicPlayer = AVAudioPlayer.createAudioPlayer(soundURL)
    musicPlayer.numberOfLoops = -1
    musicPlayer.volume = kTHBackgroundMusicValue
}

func switchMusic(urlForMusic:NSURL){
    if let m = musicPlayer {
        if m.playing {
            m.stop()
        }
    }
    prepareForMusicPlayer(urlForMusic)
    musicPlayer.prepareToPlay()
    musicPlayer.play()
}

func playRandomMusic(){
    var r = Array(orchestralMusic.values)
    r += Array(pianoMusic.values)
    r.shuffle()
    switchMusic(r[0])
}

var orchestralMusic = [
    "bee68_1" :NSBundle.mainBundle().URLForResource("bee68_1", withExtension: "mp3")!,
    "bee68_2" :NSBundle.mainBundle().URLForResource("bee68_2", withExtension: "mp3")!,
    "bee68_3" :NSBundle.mainBundle().URLForResource("bee68_3", withExtension: "mp3")!,
    "bee68_4" :NSBundle.mainBundle().URLForResource("bee68_4", withExtension: "mp3")!,
    "bee68_5" :NSBundle.mainBundle().URLForResource("bee68_5", withExtension: "mp3")!,
]

var pianoMusic = [
    "chopineb" :NSBundle.mainBundle().URLForResource("chopineb", withExtension: "mp3")!,
    "k165" :NSBundle.mainBundle().URLForResource("k165", withExtension: "mp3")!,
    "turca" :NSBundle.mainBundle().URLForResource("turca", withExtension: "mp3")!,
    "valse_n" :NSBundle.mainBundle().URLForResource("valse_n", withExtension: "mp3")!
]

var countdownMusic = NSBundle.mainBundle().URLForResource("The Countdown Clock-15s", withExtension: "mp3")!