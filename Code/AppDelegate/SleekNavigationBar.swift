//
//  SleekNavigationBar.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/21/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class SleekNavigationBar: UINavigationBar {
    
    let preferredHeight: CGFloat = 43
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code

        let image = UIImage(named: "NavigationBarBackground")
        image.drawInRect(CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, preferredHeight))
        
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        return CGSizeMake(UIScreen.mainScreen().bounds.width, preferredHeight)
    }
    
}
