//
//  QuizViewController.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import AudioToolbox

class QuizViewController: UIViewController {
    // MARK:- UI var
    @IBOutlet weak var option1: OptionButton!
    
    @IBOutlet weak var option2: OptionButton!
    
    @IBOutlet weak var option3: OptionButton!
    
    @IBOutlet weak var option4: OptionButton!
    
    @IBOutlet weak var questionView: UIView!
    
    @IBOutlet weak var timeLeftLabel: UILabel!
    
    @IBOutlet weak var removeOptionsButton: DesignableButton!
    
    @IBOutlet weak var roundIndicatorLabel: UILabel!
    @IBOutlet weak var selfProgressView: UIProgressView!
    @IBOutlet weak var selfAvatarView: AvatarRoundedView!
    @IBOutlet weak var selfScoreLabel: UILabel!
    @IBOutlet weak var selfDisplayNameLabel: UILabel!
    @IBOutlet weak var selfRankLabel: UILabel!
    
    @IBOutlet var opponentProgressView: UIProgressView!
    
    @IBOutlet weak var opponentAvatarView: AvatarRoundedView!
    
    @IBOutlet weak var opponentScoreLabel: UILabel!
    
    @IBOutlet weak var opponentDisplayNameLabel: UILabel!
    
    @IBOutlet var opponentRankLabel: UILabel!
    
    
    @IBOutlet weak var buttonSetContentView: UIView!
    
    // MARK:- ivar
    private var current_q: Int = 0
    
    private var current_timeLeft: Double = 10.0 {
        didSet{
            let timeString = current_timeLeft.format(".1")
            
            if current_timeLeft < 3.0 {
                timeLeftLabel.textColor = UIColor(hex: 0xfe0000)
            } else if current_timeLeft < 7.5 {
                timeLeftLabel.textColor = UIColor.yellowColor()
            } else {
                timeLeftLabel.textColor = UIColor.lightGrayColor()
            }
            timeLeftLabel.text = timeString
        }
    }
    
    var game: Game!
    
    private var stopwatch: NSTimer? = nil
    
    private var stopwatchStartTime: NSDate!
    
    private var currentQuestionCorrect: Bool = false
    
    private var selfTotalScore: Int = 0 {
        didSet{
            selfScoreLabel.text = String(selfTotalScore)
            let totalScore = 500 * self.game.questionSet.count
            let newProgress = Float(selfTotalScore)/Float(totalScore)
            selfProgressView.setProgress(newProgress, animated: true)
        }
    }
    
    private var didRemoveOptions: Bool = false
    
    // MARK:- init
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    // MARK:- override calls
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpPlayerDetails()
        self.questionView.alpha = 0
        self.buttonSetContentView.alpha = 0
        self.roundIndicatorLabel.alpha = 0
        dispatch_after(1, dispatch_get_main_queue(), {() in
            self.proceedToNextQuestion()
        })

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK:- methods
    func setUpPlayerDetails() {
        let thisPlayer = game.initiatingPlayer!
        let opponent = game.opponentPlayer!
        
        NetworkClient.fetchImageFromURLString(thisPlayer.pictureURL, progressHandler: nil, completionHandler: {
            image, error in
            if image != nil {
                self.selfAvatarView.image = image
            }
        })
        selfDisplayNameLabel.text = thisPlayer.displayName
        selfRankLabel.text = "Novice"
        selfTotalScore = 0
        
        NetworkClient.fetchImageFromURLString(opponent.pictureURL, progressHandler: nil, completionHandler: {
            image, error in
            if image != nil {
                self.opponentAvatarView.image = image
            }
        })
        opponentDisplayNameLabel.text = opponent.displayName
        opponentRankLabel.text = "Novice"
        //        opponentScoreLabel.text = turn.newGame ? "0" : String(turn.opponentScore)
        opponentScoreLabel.text = "Waiting.."
    }
    
    func setUpViewWithQuestion(question:Question){
        self.resetButtons()
        didRemoveOptions = false
        questionView.removeAllSubviewsExceptSubview(nil)
        questionView.addSubview(setUpQuestionViewWithQuestion(question))
        
        let optionSet = question.options.allOptions
        
        var optionButtonSet = [option1, option2, option3, option4]
        
        var i = 0
        for option in optionSet {
            optionButtonSet[i].option = option.stringContent
            if question.options.checkOptionChoiceIfIsCorrect(option) {
                optionButtonSet[i].is_answer = true
            } else {
                optionButtonSet[i].is_answer = false
            }
            i++
        }
        self.roundIndicatorLabel.alpha = 0
        switch self.current_q {
        case self.game.questionSet.count - 1:
            self.roundIndicatorLabel.text = "LAST ROUND"
        default:
            self.roundIndicatorLabel.text = "ROUND \(self.current_q + 1)"
        }
        
        UIView.animateWithDuration(1.5, delay: 0.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {() in
            self.roundIndicatorLabel.alpha = 1
            }, completion: {complete in
                UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {() in
                    self.roundIndicatorLabel.alpha = 0
                    }, completion: nil)
                
        })
        
        UIView.animateWithDuration(1.5, delay: 3.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {() in
            self.questionView.alpha = 1
            
            }, completion: nil)
        
        UIView.animateWithDuration(1.0, delay: 5.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {() in
            self.buttonSetContentView.alpha = 1
            }, completion: { completed in
                if completed {
                    self.resetRemoveOptionsButton()
                    self.timerStart()
                }
        })
    }
    
    func setUpQuestionViewWithQuestion(question:Question) -> UIView {
        if question.isGraphical() {
            var contentView = NSBundle.mainBundle().loadNibNamed("QuestionViewWithImage"
                , owner: self, options: nil)[0] as QuestionViewWithImage
            contentView.questionContent.text = question.questionContent
            switch question.questionType {
            case .LogoType:
                if let img = question.questionImage {
                    contentView.imageView.presetImage = img
                    contentView.imageView.mosaic(20)
//                    contentView.imageView.applyFilters()
                }
            default:
                if let img = question.questionImage {
                    contentView.imageView.presetImage = img
                }
            }
            return contentView
        } else {
            var contentView = NSBundle.mainBundle().loadNibNamed("QuestionViewPlain", owner: self, options: nil)[0] as QuestionViewPlain
            
            contentView.questionContent.text = question.questionContent
            return contentView
        }
    }
    
    func unmaskContentViewIfNecessary() {
        switch game.questionSet[current_q].questionType {
        case .LogoType:
            for view in questionView.subviews {
                if let logoView = view as? QuestionViewWithImage {
                    logoView.imageView.reset()
                }
            }
        default:
            break
        }
    }
    
    func resetButtons(){
        for option in [option1, option2, option3, option4] {
            option.backgroundColor = UIColor.whiteColor()
            
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
    
    func resetRemoveOptionsButton() {
        if !removeOptionsButton.enabled {
            removeOptionsButton.enable()
        }
        
        
        if removeOptionsButton.alpha == 0.5 {
            removeOptionsButton.alpha = 1
        }
    }
    func preventFurtherActions(){
        removeOptionsButton.disable()
        removeOptionsButton.alpha = 0.5
        
        for option in [option1, option2, option3, option4] {
            option.disable()
        }
    }
    
    @IBAction func optionSelected(sender: OptionButton) {
        self.timerStop()
        
        preventFurtherActions()
        
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
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "prepareToEndRound", userInfo: nil, repeats: false)
    }
    
    func prepareToEndRound() {
        current_q++
        calculateScore()
        if game.questionSet.count > current_q {
            proceedToNextQuestion()
        } else {
            endTurn()
        }
    }
    
    func calculateScore(){
        var score = selfTotalScore
        let timeTaken:Float = 0
        let timeLeft = current_timeLeft
        let timeLeftBonus =  timeLeft > 0.0 ? timeLeft/10.0 : 0.4
        let correctiveFactor = currentQuestionCorrect ? 1.0 : 0.0
        let doubleScore = 500.0 * timeLeftBonus * correctiveFactor
        score += Int(doubleScore)
        selfTotalScore = score
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
    
    func proceedToNextQuestion(){
        
        switch(self.current_q){
        case 0:
            self.setUpViewWithQuestion(self.game.questionSet[self.current_q])
        default:
            UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {() in
                self.buttonSetContentView.alpha = 0
                }, completion: nil)
            
            UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {() in
                self.questionView.alpha = 0
                
                }, completion: { c in
                self.setUpViewWithQuestion(self.game.questionSet[self.current_q])
            })
        }
    }
    
    func updateTimer(){
        let time = getTimeElasped()
        var timeLeft = 10.1 - time
        if timeLeft > 0 {
            current_timeLeft = timeLeft
        } else if timeLeft <= 0 {
            current_timeLeft = 0.0
            timerStop()
            preventFurtherActions()
            AudioServicesPlayAlertSound(0x00000FFF)
            revealCorrectAnswer()
            unmaskContentViewIfNecessary()
            NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "prepareToEndRound", userInfo: nil, repeats: false)
            
        }
    }
    
    @IBAction func removeTwoOptions(sender: AnyObject) {
        if !didRemoveOptions {
            var incorrectOptions:[OptionButton] = []
            for option in [option1, option2, option3, option4] {
                if !option.is_answer {
                    incorrectOptions.append(option)
                }
            }
            incorrectOptions.shuffle()
            UIView.animateWithDuration(0.5, animations: {()->Void in
                incorrectOptions[1].alpha = 0
                incorrectOptions[2].alpha = 0
                self.removeOptionsButton.alpha = 0.5
            })
            
            incorrectOptions[1].disable()
            incorrectOptions[2].disable()
            removeOptionsButton.disable()
        }
        didRemoveOptions = true
    }
    
    func revealCorrectAnswer() {
        for option in [option1, option2, option3, option4] {
            if option.is_answer {
                option.backgroundColor = UIColor(hex: 0x4cd964)
                option.startWobble()
                option.borderColor = UIColor.blackColor()
                option.borderWidth = 1.0
            }
        }
    }
    
    func endTurn(){
        let currentTurnScore = selfTotalScore
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func prepareGame(game:Game, hud:MBProgressHUD, completionHandler:()->()) {
        var qSet = game.questionSet
        var count:Int = 0
        for q in qSet {
            q.fetchImage() {
                ()->() in
                count += 1
                hud.progress = Float(count)/Float(game.questionSet.count)
                hud.detailsLabelText = "\(count)/\(game.questionSet.count)"
                if count == game.questionSet.count {
                    self.game = game
                    completionHandler()
                }
            }
        }
        
    }
}