//
//  Player.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/5/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

public class Player {
    public let displayName: String
    public let rank:String
    public let displayImage: UIImage
    
    public init(name dName: String, rank:String, displayPic dImage: UIImage = UIImage(named: "EmptyAvatar")){
        self.displayName = dName
        self.rank = rank
        self.displayImage = dImage
    }
}
