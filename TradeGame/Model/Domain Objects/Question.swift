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
    var questionType: QuestionType = QuestionType.LogoType
    
    /// Set of options of this current question instance.
    var options: OptionSet!
    
    /// Image content url of the question, can be nil.
    var questionImageStringName: String!
    
    var questionImage: UIImage!
    /// Initialise question with textual content, image content, set of options and type of question.
    ///
    /// :param: content Textual content of the question.
    /// :param: optionSet Set of options of the given question
    /// :param: image Image content of the question, could be a logo or a graph, etc.
    /// :param: type The immediate type of the question
    init(id:Int, content:String, optionSet:OptionSet, imageName:String?, type:QuestionType) {
        self.questionID = id
        self.questionContent = content
        self.options = optionSet
        self.questionImageStringName = imageName
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
            switch qTypeInt {
            case 1:
                self.questionType = QuestionType.LogoType
                self.questionContent = "Which stock symbol do this logo represents?"
                break
            case 2:
                self.questionType = QuestionType.GraphType
                self.questionContent = "Graph"
                break
            default:
                self.questionType = QuestionType.TextualType
                self.questionContent = "Text"
                break
            }
        }
        
        if let q: AnyObject = questionDTO["content"] {
            self.questionImageStringName = (q as String)
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
        if let imgName = self.questionImageStringName {
            var name = imgName.stringByReplacingOccurrencesOfString(" ", withString: "%20").stringByReplacingOccurrencesOfString("#", withString: "%23")
            let fqURL = "\(THImagePathHost)\(name)"
            NetworkClient.fetchImageFromURLString(fqURL, progressHandler: nil, completionHandler: {
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
            d += "Content: \(questionContent)\n"
            var imgurl = questionImageStringName ?? "no image"
            d += "Image name: \(imgurl)\n"
            d += "Type: \(questionType.description())\n"
            d += "Options: \(options)"
            d += "}\n"
            return d
    }
}
