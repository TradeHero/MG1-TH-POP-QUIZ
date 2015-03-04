//
//  QuestionDTO.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 4/3/15.
//  Copyright (c) 2015 TradeHero. All rights reserved.
//

import Argo

struct QuestionDTO: JSONDecodable, DebugPrintable {
    let questionID: Int!

    /// Textual content of the question, must not be empty.
    let questionContent: String!

    /// Type of question.
    let questionType: QuestionType = QuestionType.UnknownType

    let questionCategory: QuestionCategory = QuestionCategory.UnknownCategory

    /// Set of options of this current question instance
    let options: OptionSet!

    /// Image content url of the question, can be nil.
    let questionImageURLString: String!

    var questionImage: UIImage!

    let accessoryImageContent: String!

    var accessoryImage: UIImage!

    let subcategory: Int!

    let difficulty: Int!


    static func create(id: Int)(category: Int)(content: String)(option1: String)(option2: String)(option3: String)(option4: String)(subcategory: Int)(difficulty: Int) -> QuestionDTO {

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
            questionType = QuestionType.LogoType
            questionCategory = QuestionCategory.LogoToNameCategory
            questionContent = "Which of the following companies does this logo correspond to?"
            questionImageURLString = mainContent
        case 2:
            questionType = QuestionType.LogoType
            questionCategory = QuestionCategory.LogoToTickerSymbolCategory
            questionContent = "Which of the following ticker symbols does this logo correspond to?"
            questionImageURLString = mainContent
        case 3:
            questionType = QuestionType.TextualType
            questionCategory = QuestionCategory.NameToPriceRangeCategory
            questionContent = "In which of the price ranges did \(mainContent) recently trade?"
        case 4:
            questionType = QuestionType.TextualType
            questionCategory = QuestionCategory.NameToMarketCapRangeCategory
            questionContent = "Which of the following ranges best represents the market cap of \(mainContent)?"
        case 5:
            questionType = QuestionType.TextualType
            questionCategory = QuestionCategory.PriceRangeToCompanyNameCategory
            questionContent = "Which of the 4 companies below trades in the price range of \(mainContent)"
        case 6:
            questionType = QuestionType.TextualType
            questionCategory = QuestionCategory.HighestMarketCapCategory
            questionContent = "Which of the following companies has highest market cap?"
        case 7:
            questionType = QuestionType.TextualType
            questionCategory = QuestionCategory.LowestMarketCapCategory
            questionContent = "Which of the following companies has lowest market cap?"
        case 8:
            questionType = QuestionType.TextualType
            questionCategory = QuestionCategory.CompanyNameToExchangeSymbolCategory
            questionContent = "Identify the exchange symbol of \(mainContent)."
        case 9:
            questionType = QuestionType.TextualType
            questionCategory = QuestionCategory.OddOneOutCategory
            questionContent = "Spot the odd one from the four companies below."
        case 10:
            questionType = QuestionType.TextualType
            questionCategory = QuestionCategory.CompanyNameToSectorCategory
            questionContent = "In which sector does the \(mainContent) operate?"
        case 11:
            questionType = QuestionType.TextualType
            questionCategory = QuestionCategory.StaticCategory
            questionContent = "\(mainContent)"
        default:
            questionType = QuestionType.UnknownType
            questionContent = "~ \(content) ~"
        }

        var option1 = Option(stringContent: option1)
        var option2 = Option(stringContent: option2)
        var option3 = Option(stringContent: option3)
        var option4 = Option(stringContent: option4)

        var options = OptionSet(correctOption: option1, dummyOptions: [option2, option3, option4])

        return QuestionDTO(questionID: id, questionContent: content, questionType: questionType, questionCategory: questionCategory, options: options, questionImageURLString: questionImageURLString, questionImage: nil, accessoryImageContent: nil, accessoryImage: nil, subcategory: subcategory, difficulty: difficulty)
    }

    static func decode(j: JSONValue) -> QuestionDTO? {
        return QuestionDTO.create
                <^> j <| "id"
                <*> j <| "category"
                <*> j <| "content"
                <*> j <| "option1"
                <*> j <| "option2"
                <*> j <| "option3"
                <*> j <| "option4"
                <*> j <| "subcategory"
                <*> j <| "difficulty"
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
            d += "Options: \(options)"
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

    mutating func fetchImage(completionHandler: () -> ()) {

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

    func fetchOptionImageOperation(completionHandler: () -> ()) {
        var count: Int = 0
        for option in self.options.allOptions {
            option.fetchImage {
                count += 1
                if count == 4 {
                    completionHandler()
                }
            }
        }
    }

    mutating func fetchAccessoryImageOperation(completionHandler: () -> ()) {
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

}