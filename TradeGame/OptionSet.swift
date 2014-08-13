//
//  AnswerOptionSet.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

///Set of options that belongs to a particular question.
class OptionSet {
    
    /// Correct option or answer.
    private let correctOption: Option!
    
    /// Set of options that are not answers.
    private let dummyOptions: [Option]
    
    lazy var allOptions = [Option]()
    
    init(correctOption: Option, dummyOptions:[Option]) {
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
    func checkOptionChoiceIfIsCorrect(choice:Option) -> Bool {
        for opt in allOptions {
            ///Choice exist
            if opt === choice {
                return correctOption === choice
            }
        }
        return false
    }
}


extension OptionSet : Printable {
    var description: String {
        var d = "{\n"
            d += "Correct option: \(correctOption)\n"
            d += "Dummy options: "
            for dOpt in dummyOptions {
                d += "\(dOpt),"
            }
            d += "nil\n"
            d += "}\n"
            return d
    }
}

