//
//  MusicPlayer.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 29/10/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import AVFoundation

var orchestralMusic = [
    "Orchestral 1" :NSBundle.mainBundle().URLForResource("bee68_1", withExtension: "mp3")!,
    "Orchestral 2" :NSBundle.mainBundle().URLForResource("bee68_2", withExtension: "mp3")!,
    "Orchestral 3" :NSBundle.mainBundle().URLForResource("bee68_3", withExtension: "mp3")!,
    "Orchestral 4" :NSBundle.mainBundle().URLForResource("bee68_4", withExtension: "mp3")!,
    "Orchestral 5" :NSBundle.mainBundle().URLForResource("bee68_5", withExtension: "mp3")!,
]

var pianoMusic = [
    "Piano 1" :NSBundle.mainBundle().URLForResource("chopineb", withExtension: "mp3")!,
    "Piano 2" :NSBundle.mainBundle().URLForResource("k165", withExtension: "mp3")!,
    "Piano 3" :NSBundle.mainBundle().URLForResource("turca", withExtension: "mp3")!,
    "Piano 4" :NSBundle.mainBundle().URLForResource("valse_n", withExtension: "mp3")!
]

var countdownMusic = NSBundle.mainBundle().URLForResource("The Countdown Clock-15s", withExtension: "mp3")!

var musicPlayer: AVAudioPlayer!
var secondaryMusicPlayer = AVAudioPlayer.createAudioPlayer(countdownMusic)

var correctSoundPlayer = AVAudioPlayer.createAudioPlayer(NSBundle.mainBundle().URLForResource("Correct-Bell", withExtension: "caf")!)

var wrongSoundPlayer = AVAudioPlayer.createAudioPlayer(NSBundle.mainBundle().URLForResource("Wrong-Buzzer", withExtension: "caf")!)

func playCorrectSound(){
    if correctSoundPlayer.playing {
        correctSoundPlayer.stop()
    }
    correctSoundPlayer.numberOfLoops = 0
    correctSoundPlayer.volume = kTHSoundEffectValue
    correctSoundPlayer.play()
}

func playWrongSound(){
    if wrongSoundPlayer.playing {
        wrongSoundPlayer.stop()
    }
    wrongSoundPlayer.numberOfLoops = 0
    wrongSoundPlayer.volume = kTHSoundEffectValue
    wrongSoundPlayer.play()
}

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

func += <KeyType, ValueType> (inout left: Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

func playMusic(name: String){
    var p = orchestralMusic
    p += pianoMusic
    switchMusic(p[name]!)
}

func getRandomMusicName() -> String {
    var r = Array(orchestralMusic.keys)
    r += Array(pianoMusic.keys)
    r.shuffle()
    return r[0]
}

func playCountdownMusic(){
    if secondaryMusicPlayer.playing {
        return
    }
    
    secondaryMusicPlayer = AVAudioPlayer.createAudioPlayer(countdownMusic)
    secondaryMusicPlayer.numberOfLoops = 0
    secondaryMusicPlayer.volume = kTHBackgroundMusicValue / 2
    secondaryMusicPlayer.prepareToPlay()
    secondaryMusicPlayer.play()
    
    if let m = musicPlayer {
        if m.playing {
            m.pause()
        }
    }
}

func stopCountdownMusic(){
    secondaryMusicPlayer.stop()
    secondaryMusicPlayer.currentTime = 0
    secondaryMusicPlayer = AVAudioPlayer.createAudioPlayer(countdownMusic)
    secondaryMusicPlayer.numberOfLoops = 0
    secondaryMusicPlayer.volume = 0
    secondaryMusicPlayer.prepareToPlay()
    
    if let m = musicPlayer {
        if !m.playing {
            m.play()
        }
    }
}

