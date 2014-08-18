//
//  Question.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit


/// Type of questions, which might make question differs in presentation style.
///
/// - LogoType: Questions that presents based on logo-guessing mechanics. must contain an image.
/// - GraphType: Questions that presents based on graphs of a certain interval or demographic, must contain an image.
/// - TextualType: Questions that presents on a text-based (non-imagerial) form.
///
enum QuestionType : Int {
    case UnknownType = 0
    case LogoType
    case GraphType
    case TextualType
    
    func description() -> String {
        switch self {
        case .LogoType:
            return "Logo type"
        case .GraphType:
            return "Graph type"
        case .TextualType:
            return "Textual type"
        case .UnknownType:
            return "Unknown type"
        }
    }
}

enum QuestionCategory : Int {
    case UnknownCategory = 0
    case LogoToNameOrTickerCategory
    case NameToLastPriceCategory
    case NameToMarketCapCategory
    case NameToPECategory
    case NameToADVCategory
    case LastPriceToNameCategory
    case MarketCapToNameCategory
    case PEToNameCategory
    case ADVToNameCategory
    case TickerToNameCategory
    
    func description() -> String {
        switch self {
        case .UnknownCategory:
            return "Unknown category"
        case .LogoToNameOrTickerCategory:
            return "[1] Logo -> Name/Ticker"
        case .NameToLastPriceCategory:
            return "[2] Name -> LastPrice"
        case .NameToMarketCapCategory:
            return "[3] Name -> Market Cap"
        case .NameToPECategory:
            return "[4] Name -> Price-Earnings Ratio"
        case .NameToADVCategory:
            return "[5] Name -> Average Daily Volume"
        case .LastPriceToNameCategory:
            return "[6] LastPrice -> Name"
        case .MarketCapToNameCategory:
            return "[7] Market Cap -> Name"
        case .PEToNameCategory:
            return "[8] Price-Earnings Ratio -> Name"
        case .ADVToNameCategory:
            return "[9] Average Daily Volume -> Name"
        case .TickerToNameCategory:
            return "[10] Ticker -> Name"
        }
    }
}

/// A linguistic expression used to make a request for information.
class Question {
    
    /// ID
    let questionID: Int!
    
    /// Textual content of the question, must not be empty.
    var questionContent:String!
    
    /// Type of question.
    var questionType: QuestionType = QuestionType.UnknownType
    
    var questionCategory: QuestionCategory = QuestionCategory.UnknownCategory
    
    /// Set of options of this current question instance
    var options: OptionSet!
    
    /// Image content url of the question, can be nil.
    var questionImageURLString: String!
    
    var questionImage: UIImage!
    
    /// Initialise question with textual content, image content, set of options and type of question.
    ///
    /// :param: content Textual content of the question.
    /// :param: optionSet Set of options of the given question
    /// :param: image Image content of the question, could be a logo or a graph, etc.
    /// :param: type The immediate type of the question
    init(id:Int, content:String, optionSet:OptionSet, imageURL:String?, type:QuestionType) {
        self.questionID = id
        self.questionContent = content
        self.options = optionSet
        self.questionImageURLString = imageURL
        self.questionType = type
    }
    
    func isGraphical() -> Bool{
        switch self.questionType {
        case .LogoType, .GraphType:
            return true
        default:
            return false
        }
    }
    
    init(questionDTO:[String:AnyObject]) {
        if let id: AnyObject? = questionDTO["id"] {
            self.questionID = (id as Int)
        }
        if let qType: AnyObject = questionDTO["category"] {
            let qTypeInt = (qType as Int)
            var contentStr:String!
            if let q: AnyObject = questionDTO["content"] {
                contentStr = (q as String)
            }

            switch qTypeInt {
            case 1:
                self.questionType = QuestionType.LogoType
                self.questionCategory = QuestionCategory.LogoToNameOrTickerCategory
                self.questionContent = "Which stock symbol does this logo represents?"
                self.questionImageURLString = contentStr
            case 2:
                self.questionType = QuestionType.TextualType
                self.questionCategory = QuestionCategory.NameToLastPriceCategory
                self.questionContent = "Which of the following is the last sale price of \(contentStr)?"
            case 3:
                self.questionType = QuestionType.TextualType
                 self.questionCategory = QuestionCategory.NameToMarketCapCategory
                self.questionContent = "Which of the following is the market cap of \(contentStr)?"
            case 4:
                self.questionType = QuestionType.TextualType
                self.questionCategory = QuestionCategory.NameToPECategory
                self.questionContent = "Which of the following is the P/E ratio of \(contentStr)?"
            case 5:
                self.questionType = QuestionType.TextualType
                self.questionCategory = QuestionCategory.NameToADVCategory
                self.questionContent = "Which of the following is the average daily volume of \(contentStr)?"
            case 6:
                self.questionType = QuestionType.TextualType
                self.questionCategory = QuestionCategory.LastPriceToNameCategory
                self.questionContent = "Which company has last sale price of \(contentStr)?"
            case 7:
                self.questionType = QuestionType.TextualType
                self.questionCategory = QuestionCategory.MarketCapToNameCategory
                self.questionContent = "Which company has market cap  of \(contentStr)?"
            case 8:
                self.questionType = QuestionType.TextualType
                self.questionCategory = QuestionCategory.PEToNameCategory
                self.questionContent = "Which company has P/E ratio of \(contentStr)?"
            case 9:
                self.questionType = QuestionType.TextualType
                self.questionCategory = QuestionCategory.ADVToNameCategory
                self.questionContent = "Which company has average daily volume of \(contentStr)?"
            case 10:
                self.questionType = QuestionType.TextualType
                self.questionCategory = QuestionCategory.TickerToNameCategory
                self.questionContent = "Which name corresponds to the ticker symbol \(contentStr)?"
            default:
                self.questionType = QuestionType.UnknownType
                self.questionContent = "~"
            }
        }
        
        var option1: Option!
        if let o: AnyObject? = questionDTO["option1"] {
            option1 = Option(stringContent: (o as String))
        }
        
        var option2: Option!
        if let o: AnyObject? = questionDTO["option2"] {
            option2 = Option(stringContent: (o as String))
        }
        
        var option3: Option!
        if let o: AnyObject? = questionDTO["option3"] {
            option3 = Option(stringContent: (o as String))
        }
        
        var option4: Option!
        if let o: AnyObject? = questionDTO["option4"] {
            option4 = Option(stringContent: (o as String))
        }
        
        self.options = OptionSet(correctOption: option1, dummyOptions: [option2, option3, option4])
    }

    func fetchImage(completionHandler:() -> ()) {
        if let imgName = self.questionImageURLString {
            NetworkClient.fetchImageFromURLString(imgName, progressHandler: nil, completionHandler: {
                image, error in
                if image != nil {
                    self.questionImage = image
                }
                completionHandler()
            })

        }else{
            completionHandler()
        }
    }
}

extension Question : Printable {
    var description: String {
            var d = "{\n"
            d += "ID: \(questionID)\n"
            d += "Type: \(questionType.description())\n"
            d += "Category: \(questionCategory.description())\n"
            d += "Content: \(questionContent)\n"
            let imgurl = questionImageURLString ?? "no image"
            d += "Image name: \(imgurl)\n"
            d += "Options: \(options)"
            d += "}\n"
            return d
    }
}
