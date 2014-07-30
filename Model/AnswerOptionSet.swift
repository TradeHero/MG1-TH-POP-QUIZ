//
//  AnswerOptionSet.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
extension Array
    {
    /** Randomizes the order of an array's elements. */
    mutating func shuffle()
    {
        for _ in 0..<self.count
        {
            sort { (_,_) in arc4random() < arc4random() }
        }
    }
}
public class AnswerOptionSet {
   
    public let correctOption: AnswerOption
    public let dummyOptions: [AnswerOption]
    
    public var allOptions: [AnswerOption] = []
    public init(correctOption: AnswerOption, dummyOptions:[AnswerOption]){
        self.correctOption = correctOption
        self.dummyOptions = dummyOptions
        setupAnswerSet()
    }
    
    public func setupAnswerSet() {
        allOptions = dummyOptions
        allOptions += correctOption
        allOptions.shuffle()
    }
    
}
