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
public enum QuestionType : Int {
    case LogoType
    case GraphType
    case TextualType
}

/// A linguistic expression used to make a request for information.
public class Question {

    /// Textual content of the question, must not be empty.
    public let questionContent:String
    
    /// Type of question.
    public let questionType: QuestionType

    /// Set of options of this current question instance.
    public let options: OptionSet
    
    /// Image content of the question, can be nil.
    public let questionImage:UIImage!
    
    /// Initialise question with textual content, image content, set of options and type of question.
    ///
    /// :param: content Textual content of the question.
    /// :param: optionSet Set of options of the given question
    /// :param: image Image content of the question, could be a logo or a graph, etc.
    /// :param: type The immediate type of the question
    public init(content:String, optionSet:OptionSet, image:UIImage?, type:QuestionType) {
        self.questionContent = content
        self.options = optionSet
        self.questionImage = image != nil ? image! : nil
        self.questionType = type
    }

    public func isGraphical() -> Bool{
        switch self.questionType {
        case .LogoType, .GraphType:
            return true
        default:
            return false
        }
    }
}
