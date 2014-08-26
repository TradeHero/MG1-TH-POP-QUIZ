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
    case TimedObfuscatorType
    case TextualType
    
    func description() -> String {
        switch self {
        case .LogoType:
            return "Logo type"
        case .TimedObfuscatorType:
            return "Timed Obfuscator type"
        case .TextualType:
            return "Textual type"
        case .UnknownType:
            return "Unknown type"
        }
    }
}

enum QuestionCategory : Int {
    case UnknownCategory = 0
    case LogoToNameCategory
    case LogoToTickerSymbolCategory
    case NameToPriceRangeCategory
    case NameToMarketCapRangeCategory
    case PriceRangeToCompanyNameCategory
    case HighestMarketCapCategory
    case LowestMarketCapCategory
    case CompanyNameToExchangeSymbolCategory
    case OddOneOutCategory
    case CompanyNameToSectorCategory
    
    func description() -> String {
        switch self {
        case .UnknownCategory:
            return "Unknown category"
        case .LogoToNameCategory:
            return "[1] Logo -> Name"
        case .LogoToTickerSymbolCategory:
            return "[2] Logo -> Ticker Symbol"
        case .NameToPriceRangeCategory:
            return "[3] Name -> Price Range"
        case .NameToMarketCapRangeCategory:
            return "[4] Name -> Market Cap Range"
        case .PriceRangeToCompanyNameCategory:
            return "[5] Price Range -> Company name"
        case .HighestMarketCapCategory:
            return "[6] Highest Market Cap"
        case .LowestMarketCapCategory:
            return "[7] Lowest Market Cap"
        case .CompanyNameToExchangeSymbolCategory:
            return "[8] Company name -> Exchange symbol"
        case .OddOneOutCategory:
            return "[9] Odd one out"
        case .CompanyNameToSectorCategory:
            return "[10] Company Name -> Sector"
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
        case .LogoType, .TimedObfuscatorType:
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
                self.questionType = .LogoType
                self.questionCategory = .LogoToNameCategory
                self.questionContent = "Which of the following companies does this logo correspond to?"
                self.questionImageURLString = contentStr
            case 2:
                self.questionType = .LogoType
                self.questionCategory = .LogoToTickerSymbolCategory
                self.questionContent = "Which of the following ticker symbols does this logo correspond to?"
                self.questionImageURLString = contentStr
            case 3:
                self.questionType = .TextualType
                self.questionCategory = .NameToPriceRangeCategory
                self.questionContent = "In which of the price ranges did \(contentStr) recently trade?"
            case 4:
                self.questionType = .TextualType
                self.questionCategory = .NameToMarketCapRangeCategory
                self.questionContent = "Which of the following ranges best represents the market cap of \(contentStr)?"
            case 5:
                self.questionType = .TextualType
                self.questionCategory = .PriceRangeToCompanyNameCategory
                self.questionContent = "Which of the 4 companies below trades in the price range of \(contentStr)"
            case 6:
                self.questionType = .TextualType
                self.questionCategory = .HighestMarketCapCategory
                self.questionContent = "Which of the following companies has highest market cap?"
            case 7:
                self.questionType = .TextualType
                self.questionCategory = .LowestMarketCapCategory
                self.questionContent = "Which of the following companies has lowest market cap?"
            case 8:
                self.questionType = .TextualType
                self.questionCategory = .CompanyNameToExchangeSymbolCategory
                self.questionContent = "Identify the exchange symbol of the following company?"
            case 9:
                self.questionType = .TextualType
                self.questionCategory = .OddOneOutCategory
                self.questionContent = "Spot the odd one from the four companies below."
            case 10:
                self.questionType = .TextualType
                self.questionCategory = .CompanyNameToSectorCategory
                self.questionContent = "In which sector does the \(contentStr) operate?"
            default:
                self.questionType = QuestionType.UnknownType
                self.questionContent = "~ \(contentStr) ~"
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
                if error != nil {
                    debugPrintln(error)
                    return
                }
                if image != nil {
                    self.questionImage = image
                }
                self.fetchOptionImageOperation(completionHandler)
            })

        }else{
            self.fetchOptionImageOperation(completionHandler)
        }
    }

    func fetchOptionImageOperation(completionHandler:() -> ()){
        var count:Int = 0
        for option in self.options.allOptions {
            option.fetchImage() {
                count += 1
                if count == 4 {
                    completionHandler()
                }
            }
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
