//
//  Turn.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/5/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

/// A turn is the opportunity for a player to play the game.
public class Turn {
    
    /// Player that is playing the turn
    public let player: Player
    
    /// Opponent player of this turn.
    public let opponent: Player
    
    /// Result of this turn
//    public lazy var result = Result()
    
    public let newGame: Bool = false
    
    public let questionSet: [Question]
    
    /// 
    public init(player: Player, opponent: Player, questionSet:[Question], newGame:Bool = false){
        self.player = player
        self.opponent = opponent
        self.newGame = newGame
        self.questionSet = questionSet
    }
    
    
}
