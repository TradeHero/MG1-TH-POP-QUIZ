//
//  THIndefiniteIndicatorView.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 9/9/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class THIndefiniteIndicatorView: JGProgressHUDIndicatorView {

    init(style:JGProgressHUDStyle) {
        var indicatorView = THIndefiniteAnnularIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        switch style {
        case .ExtraLight:
            indicatorView.strokeColor = UIColor.blackColor()
        case .Light:
            indicatorView.strokeColor = UIColor.grayColor()
        case .Dark:
            indicatorView.strokeColor = UIColor.whiteColor()
        }
        super.init(contentView: indicatorView)
    }
    
    convenience override init(){
        self.init(style:.ExtraLight)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
