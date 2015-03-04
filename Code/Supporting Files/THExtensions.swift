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

extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Home", bundle: nil)
    }
    
    class func loginStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Login", bundle: nil)
    }
    
    
    class func quizStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Quiz", bundle: nil)
    }
    
    class func inAppNotificationStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "InAppNotification", bundle: nil)
    }
    class func devStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Development", bundle: nil)
    }
}