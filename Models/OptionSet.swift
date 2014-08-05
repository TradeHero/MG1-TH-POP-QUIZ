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

public class OptionSet {
   
    public let correctOption: Option
    public let dummyOptions: [Option]
    
    public lazy var allOptions = [Option]()
    
    public init(correctOption: Option, dummyOptions:[Option]){
        self.correctOption = correctOption
        self.dummyOptions = dummyOptions
        setupAnswerSet()
    }
    
    public func setupAnswerSet() {
        allOptions = dummyOptions
        allOptions.append(correctOption)
        allOptions.shuffle()
    }
    
}
