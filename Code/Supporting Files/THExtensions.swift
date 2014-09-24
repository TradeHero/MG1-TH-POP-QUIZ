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

var tableViewEssentialWidth: CGFloat {
get {
    return 0.9 * UIScreen.mainScreen().bounds.width
}
}