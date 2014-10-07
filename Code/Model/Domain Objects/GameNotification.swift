//
//  GameNotification.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 7/10/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

enum GameNotificationType: Int {
    case New
    case Nudged
    case Completed
}

class GameNotification {
    var read = true
    var type: GameNotificationType = .New
    var title: String = ""
    var details: String = ""
    var userAvatarURLString: String = ""
    
    init(type:GameNotificationType, title:String, details:String, urlString:String) {
        self.type = type
        self.title = title
        self.details = details
        self.userAvatarURLString = urlString
    }
    
    init(){}
}
