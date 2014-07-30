//
//  ViewController.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import DesignableViews

class ViewController: UIViewController {
    
    @IBOutlet weak var option1: AnswerButton!
    
    @IBOutlet weak var option2: AnswerButton!
    
    @IBOutlet weak var option3: AnswerButton!
    
    @IBOutlet weak var option4: AnswerButton!

    @IBOutlet weak var questionView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let question = createQuestion()
        option1.setTitle(question.options.allOptions[0].optionContent, forState: UIControlState.Normal)
        option2.setTitle(question.options.allOptions[1].optionContent, forState: UIControlState.Normal)
        option3.setTitle(question.options.allOptions[2].optionContent, forState: UIControlState.Normal)
        option4.setTitle(question.options.allOptions[3].optionContent, forState: UIControlState.Normal)
        
        
        if question.isWithImage {
            var contentView = QuestionViewWithImage.loadInstanceFromNib() as? QuestionViewWithImage
            contentView!.questionContent.text = question.questionContent
            contentView!.imageView.image = question.questionImage
            
            questionView = contentView
        } else {
            var contentView = QuestionViewPlain.loadInstanceFromNib() as? QuestionViewPlain
            contentView!.questionContent.text = question.questionContent
            questionView = contentView
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    func createQuestion() -> Question {
        var correctOpt = AnswerOption(stringContent: "SGX:C6L")
        var dummpOpt: [AnswerOption] = []
        dummpOpt += AnswerOption(stringContent: "SGX:D05")
        dummpOpt += AnswerOption(stringContent: "SGX:O39")
        dummpOpt += AnswerOption(stringContent: "SGX:S53")
        
        let answerSet = AnswerOptionSet(correctOption: correctOpt, dummyOptions: dummpOpt)
        
        let q = Question(content: "Which stock symbol do this logo represents?", optionSet: answerSet, image: UIImage(named: "SIA"))

        return q
    }
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
}

