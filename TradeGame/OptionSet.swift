//
//  AnswerOptionSet.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

///Set of options that belongs to a particular question.
public class OptionSet {
    
    /// Correct option or answer.
    private let correctOption: Option!
    
    /// Set of options that are not answers.
    private let dummyOptions: [Option]
    
    public lazy var allOptions = [Option]()
    
    public init(correctOption: Option, dummyOptions:[Option]) {
        self.correctOption = correctOption
        self.dummyOptions = dummyOptions
        setupAnswerSet()
    }
    
    private func setupAnswerSet() {
        allOptions = dummyOptions
        allOptions.append(correctOption)
        allOptions.shuffle()
    }
    
    ///
    /// Check if parameter option is the correct option of this question.
    ///
    /// :param: choice Option chosen.
    /// :returns: true if option exist in option set and option is correct answer of this question, false otherwise.
    ///
    public func checkOptionChoiceIfIsCorrect(choice:Option) -> Bool {
        for opt in allOptions {
            ///Choice exist
            if opt === choice {
                return correctOption === choice
            }
        }
        return false
    }
}
