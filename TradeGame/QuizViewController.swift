//
//  QuizViewController.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import DesignableViews
import Model

class QuizViewController: UIViewController {
    /*UI*/
    @IBOutlet weak var option1: OptionButton!
    
    @IBOutlet weak var option2: OptionButton!
    
    @IBOutlet weak var option3: OptionButton!
    
    @IBOutlet weak var option4: OptionButton!
    
    @IBOutlet weak var questionView: UIView!
    
    @IBOutlet weak var correctNoLabel: UILabel!
    
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    /*ivar*/
    private var current_q:Int = 0
    
    private var questionSet: [Question] = []
    
    private var totalScore: Int = 0 {
    didSet{
        scoreLabel.text = String(totalScore)
    }
    }
    
    private var correctlyAnswered: Int = 0 {
    didSet{
        correctNoLabel.text = String(correctlyAnswered)
    }
    }
    
    private var stopwatch: NSTimer? = nil
    
    private var stopwatchStartTime: NSDate? = nil
    
    private var currentQuestionCorrect: Bool = false
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        correctNoLabel.text = String(0)
        questionSet = QuestionSetFactory.sharedInstance.generateDummyQuestionSet()
        setUpViewWithQuestion(questionSet[current_q])
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
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
        self.timerStart()
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
    
    
    @IBAction func optionSelected(sender: OptionButton) {
        self.timerStop()
        
        option1.disable()
        option2.disable()
        option3.disable()
        option4.disable()
        
        currentQuestionCorrect = false
        
        if sender.is_answer {
            sender.backgroundColor = UIColor(hex: 0x4cd964)
            correctlyAnswered++
            currentQuestionCorrect = true
        } else {
            sender.backgroundColor = UIColor(hex:0xFF6A6E)
        }
        
        current_q++
        
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "finishSelectedAnswer:", userInfo: nil, repeats: false)
        calculateScore()
    }
    
    func finishSelectedAnswer(sender: NSTimer) {
        if questionSet.count > current_q {
            UIView.animateWithDuration(0.5, delay: 0.5, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: {() -> Void in
                let new_q = self.questionSet[self.current_q]
                self.setUpViewWithQuestion(new_q)
                }, completion:nil)
            
        } else {
            // done answering all questions
        }
    }
    
    func calculateScore(){
        var score = totalScore
        let timeTaken = NSString(string: timerLabel.text).floatValue
        let timeLeft = (10.0 - timeTaken) > 0.0 ? (10.0 - timeTaken)/10.0 : 0.4
        let correctiveFactor:Float = currentQuestionCorrect ? 1.0 : 0.0
        let doubleScore = 1000 * timeLeft * correctiveFactor
        score += Int(doubleScore)
        totalScore = score
    }

    
    /* timer */
    func timerStart() {
        stopwatchStartTime = NSDate()
        if stopwatch == nil {
            stopwatch = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateTimer", userInfo: nil, repeats: true)
        }
    }
    
    func timerStop() {
        stopwatch?.invalidate()
        stopwatch = nil
        
    }
    
    func updateTimer(){
        let timeNow = NSDate()
        let timeInterval = timeNow.timeIntervalSinceDate(stopwatchStartTime)
        let timerDate = NSDate(timeIntervalSince1970: timeInterval)
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "ss.S"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        let timeString = dateFormatter.stringFromDate(timerDate)
        timerLabel.text = timeString
        
    }
    
    }