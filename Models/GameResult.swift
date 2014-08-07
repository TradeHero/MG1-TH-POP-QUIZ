//
//  GameResult.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/5/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

public class GameResult {
    
//    public var game: Game!
    public var individualResults: [QuestionResult]!
    public var totalScore: Int!
    
    public init(results: [QuestionResult], score: Int){
        individualResults = results
        totalScore = score
    }
    
    public func toDictionary() -> [String: AnyObject] {
        var res:[[String: Int]] = []
        for result in individualResults {
            res += [result.toDictionary()]
        }
        
        return ["score": totalScore, "results": res]
    }
    
}
