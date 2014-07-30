//
//  ViewController.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import DesignableViews
import Model

class ViewController: UIViewController {
    
    @IBOutlet weak var option1: AnswerButton!
    
    @IBOutlet weak var option2: AnswerButton!
    
    @IBOutlet weak var option3: AnswerButton!
    
    @IBOutlet weak var option4: AnswerButton!

    @IBOutlet weak var questionView: UIView!
    
    @IBOutlet weak var correctNoLabel: UILabel!
    
    private var current_q:Int = 0
    
    private var questionSet: [Question] = []
    
    private var correctlyAnswered: Int = 0 {
    didSet{
        correctNoLabel.text = String(correctlyAnswered)
    }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        correctNoLabel.text = String(0)
        setUpQuestionSet()
        questionSet.shuffle()
        setUpViewWithQuestion(questionSet[current_q])
        // Do any additional setup after loading the view, typically from a nib.
    }

    func setUpQuestionSet() {
        questionSet += createQuestion("Which stock symbol do this logo represents?",ans:"NASDAQ:GOOG","NASDAQ:APPL","NASDAQ:MSFT","NASDAQ:JAZZ",UIImage(named: "Google"))
        questionSet += createQuestion("Which security symbol do this logo represents?",ans:"NYSE:T","NYSE:AA","NYSE:EMC","NYSE:TWTR",UIImage(named: "AT&T"))
        questionSet += createQuestion("Which security symbol do this logo represents?",ans:"SGX:C6L","SGX:D05","SGX:O39","SGX:S53",UIImage(named: "SIA"))
        questionSet += createQuestion("Which security do this stock graph of 1-month interval as of today belongs to?",ans:"NYSE:TWX","NASDAQ:WIN","NASDAQ:SIRI","SGX:S53",UIImage(named: "TestGraph1"))
        questionSet += createQuestion("Which NYSE security of the following has the highest trade volume amongst all?",ans:"CenturyLink","Citigroup","Nokia","JP Morgan",nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    func createQuestion(question:String, ans answer:String, _ opt1:String, _ opt2:String, _ opt3:String, _ image:UIImage?) -> Question {
        var correctOpt = AnswerOption(stringContent: answer)
        var dummpOpt: [AnswerOption] = []
        dummpOpt += AnswerOption(stringContent: opt1)
        dummpOpt += AnswerOption(stringContent: opt2)
        dummpOpt += AnswerOption(stringContent: opt3)
        
        let answerSet = AnswerOptionSet(correctOption: correctOpt, dummyOptions: dummpOpt)
        
        let q = Question(content: question, optionSet: answerSet, image: image)
        
        return q
    }
    
    func setUpViewWithQuestion(question:Question){
        let optionSet = question.options.allOptions

        var optionButtonSet = [option1, option2, option3, option4]
        
        var i = 0
        for option in optionSet {
            optionButtonSet[i].option = option
            optionButtonSet[i].enable()
            optionButtonSet[i].backgroundColor = UIColor.whiteColor()
            if option === question.options.correctOption {
                optionButtonSet[i].is_answer = true
            } else {
                optionButtonSet[i].is_answer = false
            }
            i++
        }
        
        
        questionView.removeAllSubviewsExceptSubview(nil)
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
            var contentView = NSBundle.mainBundle().loadNibNamed("QuestionViewPlain", owner: self, options: nil)[0] as QuestionViewPlain
            
            contentView.questionContent.text = question.questionContent
            return contentView
        }
    }
    
    
    @IBAction func optionSelected(sender: AnswerButton) {
        option1.disable()
        option2.disable()
        option3.disable()
        option4.disable()
        
        if sender.is_answer {
            sender.backgroundColor = UIColor(hex: 0x4cd964)
            correctlyAnswered++
        } else {
            sender.backgroundColor = UIColor(hex:0xFF6A6E)
        }
        
        current_q++
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "finishSelectedAnswer:", userInfo: nil, repeats: false)
        
    }
    
    func finishSelectedAnswer(sender: NSTimer) {
        if questionSet.count > current_q {
            UIView.animateWithDuration(0.5, delay: 0.5, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: {() -> Void in
                let new_q = self.questionSet[self.current_q]
                self.setUpViewWithQuestion(new_q)
                }, completion: nil)
        }
        
        
    }

    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
}

