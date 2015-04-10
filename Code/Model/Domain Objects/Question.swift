//
//  Question.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 4/3/15.
//  Copyright (c) 2015 TradeHero. All rights reserved.
//

import Argo
import Runes

/// Type of questions, which might make question differs in presentation style.
///
/// - LogoType: Questions that presents based on logo-guessing mechanics. must contain an image.
/// - TimedObfuscatorType: Questions that presents based on graphs of a certain interval or demographic, must contain an image.
/// - TextualType: Questions that presents on a text-based (non-imagerial) form.
///

enum QuestionType: Int {
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

enum QuestionCategory: Int {
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
    case StaticCategory

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
        case .StaticCategory:
            return "[11] Static questions"
        }
    }
}

class Question: JSONDecodable, DebugPrintable, Equatable {
    let questionID: Int

    let originalContent: String

    /// Textual content of the question, must not be empty.
    let questionContent: String

    /// Type of question.
    let questionType: QuestionType

    let questionCategory: QuestionCategory

    /// Set of options of this current question instance
    let correctOption: Option

    let dummyOptions: [Option]

    /// Image content url of the question, can be nil.
    let questionImageURLString: String?

    var questionImage: UIImage?

    let accessoryImageContent: String?

    var accessoryImage: UIImage?

    let subcategory: Int!

    let difficulty: Int!


    var allOptions: [Option] {
        var allOpts = dummyOptions + [correctOption]
        allOpts.shuffle()
        return allOpts
    }

    init(questionID: Int, originalContent: String, questionContent: String, questionType: QuestionType, questionCategory: QuestionCategory, correctOption: Option, dummyOptions: [Option], questionImageURLString: String?, accessoryImageContent: String?, subcategory: Int!, difficulty: Int!) {
        self.questionID = questionID
        self.originalContent = originalContent
        self.questionContent = questionContent
        self.questionType = questionType
        self.questionCategory = questionCategory
        self.correctOption = correctOption
        self.dummyOptions = dummyOptions
        self.questionImageURLString = questionImageURLString
        self.accessoryImageContent = accessoryImageContent
        self.subcategory = subcategory
        self.difficulty = difficulty
    }


        class func create(id: Int)(category: Int)(content: String)(correctOption: Option)(dummyOptions: [Option])(subcategory: Int)(difficulty: Int) -> Question {

        var questionType = QuestionType.UnknownType
        var questionCategory = QuestionCategory.UnknownCategory
        var questionContent: String!
        var questionImageURLString: String!
        var mainContent: String!
        var accessoryImageContent: String!

        var d = content.componentsSeparatedByString("|")
        if d.count == 2 {
            mainContent = d[0]
            accessoryImageContent = d[1]
        } else {
            mainContent = content
            accessoryImageContent = nil
        }


        switch category {
        case 1:
            questionType = .LogoType
            questionCategory = .LogoToNameCategory
            questionContent = "Which of the following companies does this logo correspond to?"
            questionImageURLString = mainContent
        case 2:
            questionType = .LogoType
            questionCategory = .LogoToTickerSymbolCategory
            questionContent = "Which of the following ticker symbols does this logo correspond to?"
            questionImageURLString = mainContent
        case 3:
            questionType = .TextualType
            questionCategory = .NameToPriceRangeCategory
            questionContent = "In which of the price ranges did \(mainContent) recently trade?"
        case 4:
            questionType = .TextualType
            questionCategory = .NameToMarketCapRangeCategory
            questionContent = "Which of the following ranges best represents the market cap of \(mainContent)?"
        case 5:
            questionType = .TextualType
            questionCategory = .PriceRangeToCompanyNameCategory
            questionContent = "Which of the 4 companies below trades in the price range of \(mainContent)"
        case 6:
            questionType = .TextualType
            questionCategory = .HighestMarketCapCategory
            questionContent = "Which of the following companies has highest market cap?"
        case 7:
            questionType = .TextualType
            questionCategory = .LowestMarketCapCategory
            questionContent = "Which of the following companies has lowest market cap?"
        case 8:
            questionType = .TextualType
            questionCategory = .CompanyNameToExchangeSymbolCategory
            questionContent = "Identify the exchange symbol of \(mainContent)."
        case 9:
            questionType = .TextualType
            questionCategory = .OddOneOutCategory
            questionContent = "Spot the odd one from the four companies below."
        case 10:
            questionType = .TextualType
            questionCategory = .CompanyNameToSectorCategory
            questionContent = "In which sector does the \(mainContent) operate?"
        case 11:
            questionType = .TextualType
            questionCategory = .StaticCategory
            questionContent = "\(mainContent)"
        default:
            questionType = .UnknownType
            questionContent = "~ \(content) ~"
        }

        

        return Question(questionID: id, originalContent: content, questionContent: questionContent, questionType: questionType, questionCategory: questionCategory, correctOption: correctOption, dummyOptions: dummyOptions, questionImageURLString: questionImageURLString, accessoryImageContent: accessoryImageContent, subcategory: subcategory, difficulty: difficulty)
    }

    class func decode(j: JSONValue) -> Question? {
        return Question.create
                <^> j <| "id"
                <*> j <| "category"
                <*> j <| "content"
                <*> j <| "correctOption"
                <*> j <|| "dummyOptions"
                <*> j <| "subcategory"
                <*> j <| "difficulty"
    }

    var dictionaryRepresentation: [String:AnyObject] {
        return ["id": questionID,
                "category": questionCategory.rawValue,
                "content": originalContent,
                "correctOption": correctOption.dictionaryRepresentation,
            "dummyOptions": dummyOptions.map{
                $0.dictionaryRepresentation
            },
                "subcategory": subcategory,
                "difficulty": difficulty]
    }

    var debugDescription: String {
        get {
            var d = "{\n"
            d += "ID: \(questionID)\n"
            d += "Type: \(questionType.description())\n"
            d += "Category: \(questionCategory.description())\n"
            d += "Subcategory: \(subcategory)"
            d += "Difficulty: \(difficulty)"
            d += "Content: \(questionContent)\n"
            let imgurl = questionImageURLString ?? "no image"
            d += "Image name: \(imgurl)\n"
            d += "Options: \(allOptions)"
            d += "}\n"
            return d
        }
    }


    func isGraphical() -> Bool {
        switch self.questionType {
        case .LogoType, .TimedObfuscatorType:
            return true
        default:
            return false
        }
    }

    func checkOptionChoiceIfIsCorrect(choice: Option) -> Bool {
        for opt in allOptions {
            ///Choice exist
            if opt == choice {
                return correctOption == choice
            }
        }
        return false
    }

    func fetchImage(completionHandler: () -> ()) {

        if let imgName = self.questionImageURLString {
            NetworkClient.fetchImageFromURLString(imgName, progressHandler: nil, completionHandler: {
                image, error in
                if let err = error {
                    debugPrintln(err)
                    return
                }
                if let img = image {
                    self.questionImage = img
                }
                self.fetchAccessoryImageOperation(completionHandler)
            })

        } else {
            self.fetchAccessoryImageOperation(completionHandler)
        }
    }

    func fetchAccessoryImageOperation(completionHandler: () -> ()) {
        if let imgName = self.accessoryImageContent {
            NetworkClient.fetchImageFromURLString(imgName, progressHandler: nil, completionHandler: {
                image, error in
                if let err = error {
                    debugPrintln(err)
                    return
                }
                if let img = image {
                    self.accessoryImage = img.replaceWhiteinImageWithTransparency()
                }
                self.fetchOptionImageOperation(completionHandler)
            })
        } else {
            self.fetchOptionImageOperation(completionHandler)
        }
    }

    func fetchOptionImageOperation(completionHandler: () -> ()) {
        var count: Int = 0
        var options = [correctOption] + dummyOptions

        for var i = 0; i < options.count; i++ {
            var option = options[i]
            option.fetchImage {
                count += 1
                if count == 4 {
                    completionHandler()
                }
            }
        }
    }

}

func ==(lhs: Question, rhs: Question) -> Bool {
    return lhs.questionID == rhs.questionID &&
            lhs.questionContent == rhs.questionContent &&
            lhs.questionType == rhs.questionType &&
            lhs.questionCategory == rhs.questionCategory &&
            lhs.questionImageURLString == rhs.questionImageURLString &&
            lhs.accessoryImageContent == rhs.accessoryImageContent &&
            lhs.subcategory == rhs.subcategory &&
            lhs.difficulty == rhs.difficulty; //TODO compare options
}