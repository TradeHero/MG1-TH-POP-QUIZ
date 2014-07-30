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
    
    private var current_q:Int = 0
    
    private var questionSet: [Question] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpQuestionSet()
        
        setUpViewWithQuestion(questionSet[current_q])
        // Do any additional setup after loading the view, typically from a nib.
    }

    func setUpQuestionSet() {
        questionSet += createQuestion("Which stock symbol do this logo represents?","SGX:C6L","SGX:D05","SGX:O39","SGX:S53",UIImage(named: "SIA"))
        questionSet += createQuestion("Which stock symbol do this logo represents?","SGX:C6L","SGX:D05","SGX:O39","SGX:S53",UIImage(named: "SIA"))
        questionSet += createQuestion("Which stock symbol do this logo represents?","SGX:C6L","SGX:D05","SGX:O39","SGX:S53",UIImage(named: "SIA"))
        questionSet += createQuestion("Which stock symbol do this logo represents?","SGX:C6L","SGX:D05","SGX:O39","SGX:S53",UIImage(named: "SIA"))
        questionSet += createQuestion("Which stock symbol do this logo represents?","SGX:C6L","SGX:D05","SGX:O39","SGX:S53",UIImage(named: "SIA"))
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    func createQuestion(question:String, _ answer:String, _ opt1:String, _ opt2:String, _ opt3:String, _ image:UIImage?) -> Question {
        var correctOpt = AnswerOption(stringContent: answer)
        var dummpOpt: [AnswerOption] = []
        dummpOpt += AnswerOption(stringContent: opt1)
        dummpOpt += AnswerOption(stringContent: opt2)
        dummpOpt += AnswerOption(stringContent: opt3)
        
        let answerSet = AnswerOptionSet(correctOption: correctOpt, dummyOptions: dummpOpt)
        
        let q = Question(content: question, optionSet: answerSet, image: image!)
        
        return q
    }
    
    func setUpViewWithQuestion(question:Question){
        option1.setTitle(question.options.allOptions[0].optionContent, forState: UIControlState.Normal)
        option2.setTitle(question.options.allOptions[1].optionContent, forState: UIControlState.Normal)
        option3.setTitle(question.options.allOptions[2].optionContent, forState: UIControlState.Normal)
        option4.setTitle(question.options.allOptions[3].optionContent, forState: UIControlState.Normal)
        
        questionView.subviews.map { $0.removeFromSuperview() }
        questionView.addSubview(setUpQuestionViewWithQuestion(question))
    }
    
    func setUpQuestionViewWithQuestion(question:Question) -> UIView? {
        if question.isWithImage {
            var contentView = NSBundle.mainBundle().loadNibNamed("QuestionViewWithImage"
                , owner: self, options: nil)[0] as QuestionViewWithImage
            contentView.questionContent.text = question.questionContent
            contentView.imageView.image = question.questionImage
            return contentView
        } else {
            var contentView = NSBundle.mainBundle().loadNibNamed(NSStringFromClass(QuestionViewPlain), owner: self, options: nil)[0] as QuestionViewPlain
            
            contentView.questionContent.text = question.questionContent
            return contentView
        }
    }
    
    
    @IBAction func optionSelected(sender: AnyObject) {
        option1.disable()
        option2.disable()
        option3.disable()
        option4.disable()
        
        
    }
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
}

