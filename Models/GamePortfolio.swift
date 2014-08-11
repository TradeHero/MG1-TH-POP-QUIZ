//
//  GamePortfolio.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/8/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

public class GamePortfolio {
    public let gamePortfolioID: Int!
    public let rank: String!
    
    public init(gamePfID: Int, rank: String) {
        self.gamePortfolioID = gamePfID
        self.rank = rank
    }
    
    
}
