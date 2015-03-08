//
//  OptionSetDTO.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 8/3/15.
//  Copyright (c) 2015 TradeHero. All rights reserved.
//

import UIKit

struct OptionSetDTO: DebugPrintable, Equatable {
    
    /// Correct option or answer.
    private let correctOption: OptionDTO!
    
    /// Set of options that are not answers.
    private let dummyOptions: [OptionDTO]
    
    lazy var allOptions = [OptionDTO]()

    init(correctOption: OptionDTO, dummyOptions: [OptionDTO]) {
        self.correctOption = correctOption
        self.dummyOptions = dummyOptions
        setupAnswerSet()
    }
    
    private mutating func setupAnswerSet() {
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
    func checkOptionChoiceIfIsCorrect(choice: OptionDTO) -> Bool {
        for opt in allOptions {
            ///Choice exist
            if opt == choice {
                return correctOption == choice
            }
        }
        return false
    }
    
    var debugDescription: String {
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

func ==(lhs:OptionSetDTO, rhs:OptionSetDTO) -> Bool {
    return lhs.allOptions == rhs.allOptions
        && lhs.dummyOptions == rhs.dummyOptions
}