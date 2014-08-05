//
//  QuestionSetFactory.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/31/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

public class QuestionSetFactory {
    
    public class var sharedInstance: QuestionSetFactory {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var shared : QuestionSetFactory? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.shared = QuestionSetFactory()
        }
        return Static.shared!
    }
    
    public func generateDummyQuestionSet() -> [Question] {
        var set: [Question] = []
        set.append(createQuestion("Which stock symbol do this logo represents?", qType: QuestionType.LogoType, answer:"NASDAQ:GOOG","NASDAQ:APPL","NASDAQ:MSFT","NASDAQ:JAZZ",UIImage(named: "Google")))
        set.append(createQuestion("Which security symbol do this logo represents?", qType: QuestionType.LogoType, answer:"NYSE:T","NYSE:AA","NYSE:EMC","NYSE:TWTR",UIImage(named: "AT&T")))
        set.append(createQuestion("Which security symbol do this logo represents?", qType: QuestionType.LogoType, answer:"SGX:C6L","SGX:D05","SGX:O39","SGX:S53",UIImage(named: "SIA")))
        set.append(createQuestion("Which security do this stock graph of 1-month interval as of today belongs to?", qType: QuestionType.GraphType, answer:"NYSE:TWX","NASDAQ:WIN","NASDAQ:SIRI","SGX:S53",UIImage(named: "TestGraph1")))
        set.append(createQuestion("Which NYSE security of the following has the highest trade volume amongst all?",qType: QuestionType.TextualType, answer:"CenturyLink","Citigroup","Nokia","JP Morgan",nil))
        return set
    }
    
    func createQuestion(question:String, qType type:QuestionType, answer ans:String, _ opt1:String, _ opt2:String, _ opt3:String, _ image:UIImage?) -> Question {
        let correctOpt = Option(stringContent: ans)
        var dummpOpt: [Option] = []
        dummpOpt.append(Option(stringContent: opt1))
        dummpOpt.append(Option(stringContent: opt2))
        dummpOpt.append(Option(stringContent: opt3))
        
        let answerSet = OptionSet(correctOption: correctOpt, dummyOptions: dummpOpt)
        
        let q = Question(content: question, optionSet: answerSet, image: image, type:type)
        
        return q
    }

}
