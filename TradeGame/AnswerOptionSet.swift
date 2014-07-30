//
//  AnswerOptionSet.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit



class AnswerOptionSet {
   
    let correctOption: AnswerOption
    let dummyOptions: [AnswerOption]
    
    var allOptions: [AnswerOption] = []
    init(correctOption: AnswerOption, dummyOptions:[AnswerOption]){
        self.correctOption = correctOption
        self.dummyOptions = dummyOptions
        setupAnswerSet()
    }
    
    func setupAnswerSet() {
        allOptions = dummyOptions
        allOptions += correctOption
        allOptions.shuffle()
    }
    
}
