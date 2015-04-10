//
//  FadeInSegue.swift
//  TH PopQuiz
//
//  Created by Ryne Cheow on 9/1/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class FadeInSegue: UIStoryboardSegue {

    override func perform() {
        let transition = CATransition()
        transition.duration = 1
        transition.type = kCATransitionFade

        (self.sourceViewController as! UIViewController).navigationController?.view.layer.addAnimation(transition, forKey: kCATransition)
        (self.sourceViewController as! UIViewController).navigationController?.pushViewController(self.destinationViewController as! UIViewController, animated: false)
    }
}
