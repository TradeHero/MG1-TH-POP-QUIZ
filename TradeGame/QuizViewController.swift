//
//  QuizViewController.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import Views
import Models
import AudioToolbox

class QuizViewController: UIViewController {
    /*UI*/
    @IBOutlet weak var option1: OptionButton!
    
    @IBOutlet weak var option2: OptionButton!
    
    @IBOutlet weak var option3: OptionButton!
    
    @IBOutlet weak var option4: OptionButton!
    
    @IBOutlet weak var questionView: UIView!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var selfAvatarView: AvatarRoundedView!
    
    @IBOutlet weak var opponentAvatarView: AvatarRoundedView!
    
    @IBOutlet weak var timeLeftLabel: UILabel!
    /*ivar*/
    private var current_q:Int = 0
    
    private var current_timeLeft: Double = 10.0 {
    didSet{
        let timeString = current_timeLeft.format(".1")
        
        if current_timeLeft < 3.0 {
            timeLeftLabel.textColor = UIColor(hex: 0xfe0000)
        } else if current_timeLeft < 7.5 {
            timeLeftLabel.textColor = UIColor.yellowColor()
        } else {
            timeLeftLabel.textColor = UIColor.blackColor()
        }
        timeLeftLabel.text = timeString
    }
    }
    
    private var questionSet: [Question] = []
    
    private var stopwatch: NSTimer? = nil
    
    private var stopwatchStartTime: NSDate? = nil
    
    private var currentQuestionCorrect: Bool = false
    
    private var totalScore: Int = 0 {
    didSet{
        scoreLabel.text = String(totalScore)
    }
    }
    
    
    private var removedOptions: Bool = false
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selfAvatarView.image = UIImage(named: "AvatarSample1")
        opponentAvatarView.image = UIImage(named: "AvatarSample2")
        questionSet = QuestionSetFactory.sharedInstance.generateDummyQuestionSet()
        setUpViewWithQuestion(questionSet[current_q])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    func setUpViewWithQuestion(question:Question){
        removedOptions = false
        let optionSet = question.options.allOptions
        
        var optionButtonSet = [option1, option2, option3, option4]
        
        var i = 0
        for option in optionSet {
            optionButtonSet[i].option = option.content
            optionButtonSet[i].enable()
            optionButtonSet[i].backgroundColor = UIColor.whiteColor()
            if option === question.options.correctOption {
                optionButtonSet[i].is_answer = true
            } else {
                optionButtonSet[i].is_answer = false            }
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
            switch question.questionType {
            case .LogoType:
                contentView.imageView.presetImage = question.questionImage
                contentView.imageView.mosaic(15)
            default:
                contentView.imageView.presetImage = question.questionImage
            }
            
            return contentView
        } else {
            var contentView = NSBundle.mainBundle().loadNibNamed("QuestionViewPlain", owner: self, options: nil)[0] as QuestionViewPlain
            
            contentView.questionContent.text = question.questionContent
            return contentView
        }
    }
    
    func unmaskContentViewIfNecessary() {
        switch questionSet[current_q].questionType {
        case .LogoType:
            for view in questionView.subviews {
                if let logoview = view as? QuestionViewWithImage {
                    logoview.imageView.reset()
                }
            }
        default:
            break
        }
    }
    
    func resetButtons(){
        for option in [option1, option2, option3, option4] {
            if option.wobbling {
                option.stopWobble()
            }
            if !option.enabled {
                option.enable()
            }
            
            if option.alpha == 0 {
                option.alpha = 1
            }
        }
        
    }
    @IBAction func optionSelected(sender: OptionButton) {
        self.timerStop()
        
        //        option1.disable()
        //        option2.disable()
        //        option3.disable()
        //        option4.disable()
        
        currentQuestionCorrect = false
        
        if sender.is_answer {
            sender.backgroundColor = UIColor(hex: 0x4cd964)
            currentQuestionCorrect = true
        } else {
            sender.backgroundColor = UIColor(hex:0xFF6A6E)
            revealCorrectAnswer()
            AudioServicesPlayAlertSound(0x00000FFF)
        }
        
        unmaskContentViewIfNecessary()
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "prepareToEndRound", userInfo: nil, repeats: false)
        
    }
    
    func prepareToEndRound() {
        current_q++
        if questionSet.count > current_q {
            endQuestion()
        } else {
            
        }
    }
    
    func calculateScore(){
        var score = totalScore
        let timeTaken:Float = 0
        let timeLeft = current_timeLeft
        let timeLeftBonus =  timeLeft > 0.0 ? timeLeft/10.0 : 0.4
        let correctiveFactor = currentQuestionCorrect ? 1.0 : 0.0
        let doubleScore = 1000.0 * timeLeftBonus * correctiveFactor
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
    
    func getTimeElasped() -> Double{
        let timeNow = NSDate()
        let timeInterval = timeNow.timeIntervalSinceDate(stopwatchStartTime)
        return timeInterval > 0 ? timeInterval : 0
    }
    
    func endQuestion(){
        
        calculateScore()
        
        
        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {() -> Void in
            let new_q = self.questionSet[self.current_q]
            self.setUpViewWithQuestion(new_q)
            }, completion:nil)
        self.resetButtons()
        
    }
    
    func updateTimer(){
        let time = getTimeElasped()
        var timeLeft = 10.0 - time
        if timeLeft > 0 {
            current_timeLeft = timeLeft
        } else if timeLeft <= 0 {
            self.timerStop()
            AudioServicesPlayAlertSound(0x00000FFF)
            revealCorrectAnswer()
            unmaskContentViewIfNecessary()
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "prepareToEndRound", userInfo: nil, repeats: false)
        }
    }
    
    @IBAction func removeTwoOptions(sender: AnyObject) {
        if !removedOptions {
            var incorrectOptions:[OptionButton] = []
            for option in [option1, option2, option3, option4] {
                if !option.is_answer {
                    incorrectOptions += option
                }
                incorrectOptions.shuffle()
            }
            
            UIView.animateWithDuration(0.5, animations: {()->Void in
                incorrectOptions[1].alpha = 0
                incorrectOptions[2].alpha = 0
                })
            
            incorrectOptions[1].disable()
            incorrectOptions[2].disable()
        }
        removedOptions = true
    }
    
    func revealCorrectAnswer() {
        for option in [option1, option2, option3, option4] {
            if option.is_answer {
                option.backgroundColor = UIColor(hex: 0x4cd964)
                option.startWobble()
            }
        }
    }
    
}