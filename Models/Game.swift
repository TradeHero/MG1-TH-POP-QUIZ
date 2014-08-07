//
//  Game.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/7/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

public class Game {

    public let gameID: Int
    public let initiatingPlayer:Player
    public let opponentPlayer:Player
    public let winningPlayer: Player? = nil
    
    public init(id: Int, initiator:Player, opponent:Player) {
        gameID = id
        initiatingPlayer = initiator
        opponentPlayer = opponent
    }
}
